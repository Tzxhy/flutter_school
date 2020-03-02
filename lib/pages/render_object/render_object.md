## 渲染对象
在 flutter 中，我们通常可以使用官方提供的大量 widget，即使官方没有提供，也能通过 `Stack`、`Row` 等布局组件来实现一些自定义的组件。不过，组合一些组件，来实现一些复杂的通用组件（尤其是涉及到频繁交互而导致频繁绘制的），性能高吗？回答这个问题前，先思考一下：如何实现 iOS 风格的 Switch？如果你的答案是利用`Stack`来层层放置已有组件，那你就需要学习这篇教程了；如果你的答案是基于`RenderObjectWidget`来实现自定义整个绘制流程，或者说利用类似`CustomPaint`这种自定义绘制的方案，那么本教程对你应该作用不大，可以跳过。

## widget-element-renderObject 关系
具体参考[widget-element-renderObject](https://www.tanzhixuan.top/2019/10/04/flutter%E4%B8%ADwidget-element-renderObject%E5%85%B3%E7%B3%BB/#more)。不赘述。

