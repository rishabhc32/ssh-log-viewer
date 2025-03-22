import Foundation

// Enum to designate navigation actions.
public enum NavigationAction {
    case to(path: String)
    case back
    case forward
}

// A class to handle navigation state and actions for a host.
public class NavigationState {
    public var currentPath: String
    public var backStack: [String]
    public var forwardStack: [String]

    public init(
        currentPath: String, backStack: [String] = [], forwardStack: [String] = []
    ) {
        self.currentPath = currentPath
        self.backStack = backStack
        self.forwardStack = forwardStack
    }

    public var canNavigateBack: Bool {
        return !backStack.isEmpty
    }

    public var canNavigateForward: Bool {
        return !forwardStack.isEmpty
    }

    // Updates navigation state based on the provided action
    // Returns the target path if navigation was successful, nil otherwise
    public func updateNavigation(action: NavigationAction) -> String? {
        var targetPath: String = currentPath

        switch action {
        case .to(let path):
            // Skip if trying to navigate to the current path
            if path == currentPath { return nil }

            backStack.append(currentPath)
            forwardStack.removeAll()
            targetPath = path
        case .back:
            guard let previousPath = backStack.popLast() else { return nil }
            forwardStack.append(currentPath)
            targetPath = previousPath
        case .forward:
            guard let nextPath = forwardStack.popLast() else { return nil }
            backStack.append(currentPath)
            targetPath = nextPath
        }

        currentPath = targetPath
        return targetPath
    }
}
