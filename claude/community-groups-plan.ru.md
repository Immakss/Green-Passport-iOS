# План: группы с чатом и приглашениями, починка отправки на форуме


## Контекст
- Экрана группы, добавления людей и сообщений в группах никогда не было, ни на iOS, ни на Android. По спеке 6.14 группы — это только «создать / вступить». В `firestore.rules` заготовлены `chats/{chatId}/messages`, но клиентского кода нет.
- Дыра в правилах: `groups` разрешает любому пользователю переписать `memberIds` чужой группы, то есть выкинуть всех.
- Форум, по словам пользователя, не отправляет посты. При этом `ForumViewModel.post()` глотает ошибку (`hasError` ставится только при пустой ленте), так что пользователь не видит причину.

Решения пользователя:
- группы публичные: список видят все, вступить может любой;
- чат читают и пишут только участники;
- людей добавляют по коду приглашения (кнопка «Пригласить» → системный share).

## 1. Форум: найти причину и показывать ошибку
1. Диагностика (до правок): прогнать `rules-tests` в эмуляторе со сценарием «создание поста с `authorAvatar` и `authorName`». Сравнить задеплоенные правила с репозиторием: `firebase firestore:rules:get` или консоль. Залогировать реальную ошибку `postToForum` (`FirestoreErrorCode`).
2. Независимо от причины: при неудаче поста показывать текст под полем ввода, а не молчать.
```swift
} catch {
    uiState.sendFailure = (error as? ContentRejectedError) == nil ? .network : nil
}
```
   Новый ключ `message_not_sent_msg`: «Не удалось отправить. Проверьте интернет и попробуйте ещё раз» (ru/be/en).
3. Причину исправить там, где она найдётся: правила, данные или клиент. После правок правил — `firebase deploy --only firestore:rules` (с подтверждения пользователя).

## 2. Данные (Firestore, общие для обеих платформ)
- `groups/{groupId}`: к `name` и `memberIds` добавляются `ownerId`, `createdAtEpochMillis` и `inviteCode`. Код — 6 символов из алфавита купонов `ABCDEFGHJKMNPQRSTUVWXYZ23456789`.
- `chats/{groupId}/messages/{messageId}`: `senderId`, `senderName`, `senderAvatar`, `text`, `createdAtEpochMillis`. Id чата равен id группы.
- Старым группам без `inviteCode` и `ownerId` проставляет значения разовый скрипт `scripts/backfill-groups.js` (service account, как `seed-firestore.js`).

## 3. Правила (`firestore.rules`) и тесты (`rules-tests`)
```
match /apps/greenpassport/groups/{groupId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && isCleanText(request.resource.data.name, 60) &&
    request.resource.data.ownerId == request.auth.uid &&
    request.resource.data.memberIds == [request.auth.uid] &&
    request.resource.data.inviteCode is string && request.resource.data.inviteCode.size() == 6;
  allow update: if request.auth != null &&
    request.resource.data.diff(resource.data).affectedKeys().hasOnly(['memberIds']) &&
    (isJoining() || isLeaving());
  allow delete: if false;
}

function isJoining() {
  return request.resource.data.memberIds.toSet().difference(resource.data.memberIds.toSet()) == [request.auth.uid].toSet() &&
    resource.data.memberIds.toSet().difference(request.resource.data.memberIds.toSet()).size() == 0;
}

function isLeaving() {
  return resource.data.memberIds.toSet().difference(request.resource.data.memberIds.toSet()) == [request.auth.uid].toSet() &&
    request.resource.data.memberIds.toSet().difference(resource.data.memberIds.toSet()).size() == 0;
}

function isGroupMember(groupId) {
  return request.auth.uid in get(/databases/$(database)/documents/apps/greenpassport/groups/$(groupId)).data.memberIds;
}

match /apps/greenpassport/chats/{groupId}/messages/{messageId} {
  allow read: if request.auth != null && isGroupMember(groupId);
  allow create: if request.auth != null && isGroupMember(groupId) &&
    request.resource.data.senderId == request.auth.uid &&
    isCleanText(request.resource.data.text, 2000) &&
    isCleanOptionalText(request.resource.data, 'senderName', 61);
  allow update, delete: if false;
}
```
Тесты в `rules-tests`:
- можно добавить или убрать только себя;
- чужого удалить нельзя;
- создатель группы — единственный участник;
- не участник не читает и не пишет чат;
- пост форума с `authorAvatar` проходит.

## 4. iOS — domain и data
- `CommunityGroup`: добавить `ownerId: String?` и `inviteCode: String?`.
- Новая модель `GroupMessage` (`id`, `senderId`, `senderName`, `senderAvatar`, `text`, `sentAt`).
- Новая модель `GroupMember` (`id`, `name`, `avatar`).
- `CommunityRepository` получает:
```swift
func observeGroup(id: String) -> AsyncThrowingStream<CommunityGroup?, Error>
func findGroup(inviteCode: String) async throws -> CommunityGroup?
func leaveGroup(groupId: String, userId: String) async throws
func observeMessages(groupId: String) -> AsyncThrowingStream<[GroupMessage], Error>
func sendMessage(groupId: String, senderId: String, senderName: String?, senderAvatar: AvatarStyle?, text: String) async throws
func fetchMembers(ids: [String]) async throws -> [GroupMember]
```
- `createGroup` пишет `ownerId`, `createdAtEpochMillis` и `inviteCode`. Генератор `InviteCodeGenerator` — порт `couponCode.ts`.
- `fetchMembers` читает `users/{id}` через `firstValue()` (кеш-first), по 10 штук параллельно.
- Use cases (по одному на файл): `ObserveGroupUseCase`, `JoinGroupByCodeUseCase`, `LeaveGroupUseCase`, `ObserveGroupMessagesUseCase`, `SendGroupMessageUseCase` (фильтр мата и имя из профиля, как в `PostToForumUseCase`), `FetchGroupMembersUseCase`.

## 5. iOS — presentation
- **Список групп** (`GroupsScreen`):
  - строка открывает группу: `router.push(.group(id:))`, добавить case в `AppDestination` и `AppDestinationView`;
  - в тулбаре кнопка «Вступить по коду» → alert с полем;
  - код не найден → `group_not_found_msg`.
- **Экран группы** (`GroupDetailRoute` / `GroupDetailScreen` / `GroupDetailViewModel` / `GroupDetailUiState`):
  - участник видит чат: сообщения снизу вверх, свои — справа плашкой `MintSurfaceHigh`, чужие — с аватаром и именем;
  - внизу поле ввода, общий компонент `MessageComposer`, вынесенный из `ForumScreen`;
  - не участник видит название, число участников и кнопку «Вступить», чат скрыт;
  - тулбар-меню: «Участники» (шторка со списком), «Пригласить» (`ShareLink`), «Покинуть группу» (с подтверждением);
  - текст приглашения: `group_invite_share_msg` «Присоединяйся к группе «%1$@» в Зелёном паспорте. Код: %2$@».
- Ошибка отправки — текст под полем ввода (`message_not_sent_msg`), мат — `text_contains_banned_words`.
- Клавиатура: `.scrollDismissesKeyboard(.interactively)` плюс `dismissesKeyboardOnBackgroundTap()`, по правилам репо.
- Новые строки (ru/be/en):
  - `group_members`, `invite`, `leave_group`, `leave_group_confirm_msg`;
  - `join_by_code`, `invite_code`, `group_not_found_msg`;
  - `group_invite_share_msg`, `group_chat_empty_msg`, `join_group_to_chat_msg`, `message_not_sent_msg`.

## 6. Спека и Android
- Спека 6.14: экран группы, чат только для участников, приглашение по коду, выход из группы, ошибка отправки.
- Android backlog: тот же экран группы и чат, «Вступить по коду», показ ошибки отправки на форуме.
- Код Android в этой задаче не меняется. Меняются только общие правила, тесты правил и скрипт миграции в Android-репо.


## 6a. Совместимость Android с новыми правилами
`allow create` для `groups` требует `ownerId` и `inviteCode`, а Android `FirestoreCommunityRepository.createGroup` пишет только `name` и `memberIds`. После деплоя правил создание группы на Android упадёт с `PERMISSION_DENIED`. Поэтому в этой же задаче Android минимально правится без UI: `createGroup` пишет `ownerId`, `createdAtEpochMillis` и `inviteCode` (генератор `InviteCodeGenerator` в `core`, порт `couponCode.ts`), а мёртвый код чата переходит с `sentAtEpochMillis` на `createdAtEpochMillis`.
```kotlin
object InviteCodeGenerator {
    private const val ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
    private const val LENGTH = 6

    fun generate(): String {
        val random = SecureRandom()
        return (1..LENGTH).map { ALPHABET[random.nextInt(ALPHABET.length)] }.joinToString("")
    }
}
```

## Проверка
```bash
xcodebuild -project "Green Passport.xcodeproj" -scheme "Green Passport" \
  -destination 'generic/platform=iOS Simulator' build
cd ~/Personal/greenpassport-android && firebase emulators:exec --only firestore,storage "npm --prefix rules-tests test"
```
После деплоя правил (`firebase deploy --only firestore:rules`, с подтверждения пользователя) и `node scripts/backfill-groups.js`, сценарии на двух аккаунтах:
1. Форум: пост отправляется и появляется в ленте. В авиарежиме под полем видна ошибка.
2. A создаёт группу и открывает её. Чат пустой (`group_chat_empty_msg`), A пишет сообщение.
3. A → «Пригласить» → код. B → «Вступить по коду» → попадает в группу и видит сообщение A. Ответ B сразу виден у A.
4. Не участник C открывает группу из списка: чата нет, есть «Вступить».
5. B → «Покинуть группу»: чат пропадает, число участников уменьшается. Попытка удалить чужого из `memberIds` отклоняется правилами (тест).
6. Мат в сообщении → `text_contains_banned_words`. Светлая и тёмная тема.
