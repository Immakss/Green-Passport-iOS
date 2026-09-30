enum ProfileSetupUserAction {
    case firstNameChanged(String)
    case lastNameChanged(String)
    case citySelected(String)
    case interestToggled(TaskCategory)
    case avatarSelected(AvatarStyle)
    case back
    case next
    case signOut
}
