class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    layout = UICollectionViewFlowLayout.alloc.init
    rootViewController = MainController.alloc.initWithCollectionViewLayout(layout)
    rootViewController.title = 'empty-test'
    rootViewController.view.backgroundColor = UIColor.whiteColor

    navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = navigationController
    @window.makeKeyAndVisible

    true
  end
end
