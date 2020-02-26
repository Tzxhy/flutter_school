# 数据最小化更新方式
在这个文件夹中，列举了几种笔者认为的可以最小化更新的方式。何为最小化？update_data.md 中也说过，调用 `setState` 后，会 rebuild 当前 state 的 child 及子孙组件（**child 非 const 组件**）。这里差几句话，先来讨论一下，为啥 const 组件不会 rebuild？

在 Dart 语言中，`const` 关键字表示编译时常量，啥意思？就是编译之后，这是一个上下文相关的固定值，即使是对象，也是一直引用到某个对象的引用。可以参考 case2.dart 中的样例。在使用 const 构造组件`Case2`时，每次 state 引起的 rebuild，Case2 组件都能够『幸免于难』不被 rebuild，因为 const 组件就类似于在这一处使用的全局唯一不变的一个引用。每次 rebuild 都是使用这一个引用，当然不会重新实例化一个组件，也不会走 rebuild 的逻辑了。很好吧？ 那么问题来了：既然 const 组件不会 rebuild，那么怎么更新 UI 呢？
可以参考：[flutter: when const widgets are rebuilt?](https://stackoverflow.com/questions/56666339/flutter-when-are-const-widgets-rebuilt)。方法就是：对于无状态组件，需要用 `InheritedWidget` 来实现数据更新；对于有状态组件，会触发 `didDependenciesChange` 回调，进而 rebuild。

扯远了。我们回到主题。怎么最小化更新？而不是一次小更新，导致整个应用刷新一遍，显然不符合高效性能最优。那么我们有什么方案呢？这里我提出几种方案（可能归根结底是一种）。

## page/app 级别的观察者 + 多个单状态InheritedWidget
