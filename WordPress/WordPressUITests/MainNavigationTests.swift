import XCTest
import VSMobileCenterExtensions

class MainNavigationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // Logout first if needed
        logoutIfNeeded()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        logoutIfNeeded()
        super.tearDown()
    }

    func testTabBarNavigation() {
        let app = XCUIApplication()
        let mainNavigationTabBar = app.tabBars["Main Navigation"]
        simpleLogin(username: WordPressTestCredentials.oneStepUser, password: WordPressTestCredentials.oneStepPassword)
        self.waitForElementToAppear(element: mainNavigationTabBar)

        MCLabel.labelStep("Launched app and logged int")
        mainNavigationTabBar.buttons["My Sites"].tap()
        mainNavigationTabBar.buttons["My Sites"].tap()
        self.waitForElementToAppear(element: app.tables["Blogs"])

        mainNavigationTabBar.buttons["Reader"].tap()
        self.waitForElementToAppear(element: app.tables["Reader"])
        MCLabel.labelStep("Reader")

        mainNavigationTabBar.buttons["Me"].tap()
        self.waitForElementToAppear(element: app.staticTexts["Me"])
        MCLabel.labelStep("Me")

        mainNavigationTabBar.buttons["Notifications"].tap()
        self.waitForElementToAppear(element: app.staticTexts["Notifications"])
        MCLabel.labelStep("Notificatios")

        mainNavigationTabBar.buttons["New Post"].tap()
        MCLabel.labelStep("New Post")
        app.navigationBars["WPPostView"].buttons["Cancel"].tap()
    }

}
