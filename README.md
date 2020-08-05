# DependencyInjection

A microframework for dependency injection based on the service locator pattern utilizing Swift's property wrappers.

## Usage
On App start register dependencies by overriding AppDelegate's initializer:
```Swift
import DependencyInjection
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    @LazyInject private var config: AppConfiguration
    @LazyInject private var router: Router

    override init() {
        super.init()

        DIContainer.register {
            Shared(AppConfigurationImpl() as AppConfiguration)
            Shared(RouterImpl() as Router)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // use `config` and `router`

        return true
    }
}
```
### Lazy vs eager evaluation
As the initializers of the injected properties the example above would be called before the AppDelegate's initializer, it's necessary to separate usage and initialization of the injected property. `@LazyInject` will only resolve when its property is first accessed. To resolve properties eagerly use `@Inject` instead.

### Optional dependencies
Dependencies that under certain circumstances cannot be resolved can simply be marked as `Optional`s.
```Swift
@Inject var player: MediaPlayer?
```
If no `MediaPlayer` instance is registered, `player` resolves to `nil`.
Note: If an Optional would be registered `player` also resolves to `nil` as the registered type is not the expected `MediaPlayer` but `Optional<MediaPlayer>` in this case.

### Shared vs new instances
Registering a dependency as `Shared` will always resolve to the same (identical) instance. To get a new instance in each property use `New`:
```Swift
DIContainer.register(New(MockRouter.init as Router))
```
By doing so registrations made in production code could for example be overridden by mock objects in tests that are not shared across objects.

### Aliases
Instances can also be registered with multiple alias protocols that each only expose certain parts of their functionality:
```Swift
DIContainer.register(Shared(RouterImpl.init, as: Router.self, DeeplinkHandler.self))
```

### Registering dependencies that have dependencies themselves
In case the registered dependencies depend on other dependencies themselves that should be passed via initializer injection there are overloads for registering `Shared` and `New` instances that pass a `Resolver` object in a closure:
```Swift
DIContainer.register {
    Shared { resolve in RouterImpl(config: resolve()) }
}
```

### Modules
To group dependencies it's an option to use DI Modules. Those are convenience wrappers around registrations and can either be defined in different parts of the code base and then registered themselves e.g. in AppDelegate:
```Swift
// Feature 1

struct FeatureOneDependencyInjection {
    static let module = Module {
        Shared(FeatureOneImplementation.init as FeatureOne)
        New(FeatureOneViewModelImplementation.init as FeatureOneViewModel)
    }
}

// Feature 2

struct FeatureTwoDependencyInjection {
    static let module = Module(Shared(FeatureTwoImplementation.init as FeatureTwo))
}

// AppDelegate

override init() {
    super.init()

    DIContainer.register {
        FeatureOneDependencyInjection.module
        FeatureTwoDependencyInjection.module
    }
}
```

Alternatively Modules could also be used inline in a central location:
```Swift
DIContainer.register {
    Module {
        Shared(FeatureOneImplementation.init as FeatureOne)
        New(FeatureOneViewModelImplementation.init as FeatureOneViewModel)
    }
    Module {
        Shared(FeatureTwoImplementation.init as FeatureTwo)
    }
}
```

### Usage without property wrappers
As property wrappers can currently not be used inside function bodies, dependencies can be resolved "manually":
```Swift
func foo() {
    DIContainer.resolve(Router.self)
}
```

or if the compiler can infer the type to resolve:
```Swift
func foo() {
    bar(router: DIContainer.resolve())
}

func bar(router: Router) {
    // …
}
```

### Parameterized resolution
If inversion of control should not only be applied to types where all parameters are present on registration it's possible to provide arguments at a later point, when resolving the dependency:
```Swift
func register() {
    DIContainer.register {
        New({ resolver, id in ConcreteViewModel(id: id) }, as: ViewModelProtocol.self)

        // alternatively:
        New { _, id in ConcreteViewModel(id: id) as ViewModelProtocol }
    }
}
```

The `id` argument needs to be provided to use an instance implementing `ViewModelProtocol`. The first argument `resolver` can be used or ignored to resolve further arguments via dependency injection. Providing the argument is done in a closure:
```Swift
func resolve() -> ViewModelProtocol {
    DIContainer.resolve(ViewModelProtocol.self, arguments: { "id_goes_here" })

    // multiple arguments are provided as tuple:
    DIContainer.resolve(PresenterProtocol.self) { ("argument 1", 23, "argument 3") }
}
```

As initializers of properties (and Property Wrappers for that matter) are called before `self` is available in Swift only hard coded arguments could be provided in initalizers of `@Inject` and `@LazyInject`. Parameterized resolution is therefore currently limited to the `resolve` method of `DIContainer` as shown above.
