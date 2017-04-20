import XCTest
import VSMobileCenterExtensions

class LoginTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        XCUIApplication().launch()
        app = XCUIApplication()

        sleep(2) // stabilize launch before screenshot
        // Logout first if needed
        logoutIfNeeded()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        logoutIfNeeded()
        super.tearDown()
    }

    func testSimpleLogin() {
        MCLabel.labelStep("Launched app")
        simpleLogin(username: WordPressTestCredentials.oneStepUser, password: WordPressTestCredentials.oneStepPassword)

        waitForElementToAppear(element: app.tabBars[ elementStringIDs.mainNavigationBar ])
        MCLabel.labelStep("Logged In")
    }

    func testUnsuccessfulLogin() {
        MCLabel.labelStep("Launched app")
        simpleLogin(username: WordPressTestCredentials.oneStepUser, password: "password")

        waitForElementToAppear(element: app.images[ "icon-alert" ])
        MCLabel.labelStep("Bad credentials alert")
        app.buttons.element(boundBy: 1).tap()
    }

    /*
    func testSelfHostedLoginWithoutJetPack() {
        loginSelfHosted(username: WordPressTestCredentials.selfHostedUser, password: WordPressTestCredentials.selfHostedPassword, url: WordPressTestCredentials.selfHostedSiteURL)

        waitForElementToAppear(element: app.tabBars[ elementStringIDs.mainNavigationBar ], timeout: 10)

        logoutSelfHosted()
    }

    func testCreateAccount() {
        let username = "\(WordPressTestCredentials.oneStepUser)\(arc4random())"
        let email = WordPressTestCredentials.nuxEmailPrefix + username + WordPressTestCredentials.nuxEmailSuffix

        createAccount(email: email, username: username, password: WordPressTestCredentials.oneStepPassword)
        waitForElementToAppear(element: app.tabBars[ elementStringIDs.mainNavigationBar ], timeout: 20)
    }
 */
}
