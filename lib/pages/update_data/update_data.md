
# 数据更新方式

## 前言
在 flutter 中，数据的更新存放于 `State` 对象中。`State` 类有一个方法叫做`setState`，该方法是更新数据的基础方法。今天我们要讨论的是 flutter 中更新数据的几种方式，以及他们之间的优缺点、使用场景等。


## 更新方式
虽然有很多种状态管理方案，但最基础的都是使用 `setState` 来更新数据，至于怎么最小化更新，则是需要考虑的问题。

### setState
这个是最传统的方式了。当在某一个 `State` 下调用 `setState` 时，会 rebuild 该 state `build` 方法返回的组件（**非 const 组件**）。当然，考虑到性能问题，flutter 采用了这样的方式：rebuild 所有 widget，element 能复用则复用。复用条件：runType 相等并且 key 相同（如有）。所以在设计组件时，可以考虑将有状态的组件安排到 `widget` 叶节点上，这样 rebuild 时就不会 rebuild 大量 widget 节点以及 element 复用检验等，但是对于整个 app 的状态来说，怎么维护这个状态，就需要思考下了。

代码参考 set_state.dart。主要是：在 `State` 对象属性改变后，调用 `setState` 方法，将该 Widget 对应的 Element 标记为 dirty，在下一次系统发出 vsync 信号后，刷新整个界面。

`setState` 是视图更新的唯一入口：其他数据更新方式，都是基于底层使用 `setState` 来做的。

### BLoC
BLoC，全称：Business Logic Component，业务逻辑组件。简单来说，就是将业务逻辑和组件解耦，便于代码管理。可以类比 css 之于 html 的划分。flutter 的 bloc [库地址](https://pub.dev/packages/bloc)。整个流程示意图：
![BLoC](https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png)
在 flutter 中，业务逻辑通过流传递数据给 UI ；UI 通过事件回调，调用BLoC 模块的 handler。

具体代码参见：bloc.dart。

在 flutter 中，实现了 `StreamBuilder` 组件，通过传入一个 Stream，由组件注册监听 Stream 的数据。当数据传来时，便在 flutter 的更新周期中更新。这通常没有什么问题，但某些 case 下，会『有问题』。比如 flutter 一秒更新60次，但实际流中数据一秒更新了120次，那么实际只会更新60次，其他的状态都丢了。但对于视觉来说，这是没有影响的。

### ValueNotifier
ValueNotifier 是实现了观察者模式的类。当 `value` 改变后，会通知所有注册过回调的观察者，观察者可以根据该 value 的变化，决定是否更新视图。当然，需要使用到 `ValueNotifier` 这个类的都应该是某个 `State`，因为只有 `State` 才有生命周期，才能决定是否更新。

举个例子，比如：页面根组件为一个有状态组件，生成一个包含页面整个数据的 `ValueNotifier` 对象，通过一个 `InheritedWidget` 向下传递该观察者对象和全局数据 value，在需要状态的组件中绑定回调。这样，当 value 更新时，会通知所有注册过的组件，这些组件可以选择是否更新以及更新的数据，以及通过 `InheritedWidget` 获取数据的组件。参考 page/case1.dart 代码。


### InheritedWidget
继承组件。flutter 中有很多 UI 组件，但也有很多功能组件，比如 `InheritedWidget`。它有啥用呢？具体可以看文末的__Inheriting Widgets__这篇文章。它的作用，让组件树的深层组件能够直接获取到该节点，当然也能获取到该节点的数据，避免了数据一层一层向下传递。同时，该组件还有一个功能：在它自身被 rebuild 时，会调用方法 `updateShouldNotify`，判断是否需要通知使用了它数据的组件：可以是无状态组件，直接触发 build；也可以是有状态组件，`didDependenciesChange` 回调会被触发。

在使用 InheritedWidget 的选择性更新的功能时，确保它的 Widget child 是 const 的。

用例参考 inherited.dart。

每一个 `InheritedWidget` 都应该包含尽量少的数据，比如，登录状态可以作为一个，当前余额信息作为一个，而不是把两者何在一个 `InheritedWidget` 里。为什么呢？如果合在一起，只是余额变了，而登录状态未变，会导致依赖于登录状态的组件 rebuild。 

### 总结


### 参考
[Flutter State Management: setState, BLoC, ValueNotifier, Provider](https://medium.com/coding-with-flutter/flutter-state-management-setstate-bloc-valuenotifier-provider-2c11022d871b)
[Inheriting Widgets](https://medium.com/@mehmetf_71205/inheriting-widgets-b7ac56dbbeb1)

