# DependencyInjection

A microframework for dependency injection based on the service locator pattern utilizing Swift's property wrappers.

## Usage
On App start register dependencies by overriding AppDelegate's initializer:
```
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    @LazyInject private var config: AppConfiguration
    @LazyInject private var router: Router

    override init() {
        super.init()

        DIContainer.shared.register {
            Shared(AppConfigurationImpl() as AppConfiguration)
            Shared(RouterImpl() as Router)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // use `config` and `router`

        return true
    }
```

As instance properties are initialized before running the initializer in Swift, it's necessary to separate usage and initialization of the injected property. `@LazyInject` will only resolve when its property is first accessed. To resolve properties eagerly use `@Inject` instead.

Registering a dependency as `Shared` will always resolve to the same (identical) instance. To get a new instance in each property use `New`:
```
DIContainer.shared.register(New(MockRouter.init as Router))
```
By doing so registrations made in production code could for example be overridden by mock objects in tests that are not shared across objects.

Instances can also be registered with multiple alias protocols that each only expose certain parts of their functionality:
```
DIContainer.shared.register(Shared(RouterImpl.init, as: Router.self, Navigator.self))
```

In case the registered dependencies depend on other dependencies themselves that should be passed via initializer injection there are overloads for registering `Shared` and `New` instances that pass a `Resolver` object in a closure:
```
DIContainer.shared.register {
    Shared { RouterImpl(config: $0.resolve()) }
}
```
