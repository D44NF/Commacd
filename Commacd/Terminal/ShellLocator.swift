import Darwin

enum ShellLocator {
    static func loginShellPath() -> String {
        guard let passwd = getpwuid(getuid()) else { return "/bin/zsh" }
        return String(cString: passwd.pointee.pw_shell)
    }
}
