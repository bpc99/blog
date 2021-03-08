---
title: react导航守卫
date: 2020-12-22 15:02:21
subtitle: react-router
tags:
  - React
  - 导航守卫
categories: [web]
---
导航守卫在日常开发中经常会被使用到，比如一个界面需要登陆之后或需要某种权限才能进行访问，这样我们可以很简单的使用导航守卫实现。

<!-- more -->
## 导航守卫
vue 的导航守卫主要分为 3 种，分别为：`全局导航守卫`、`路由导航守卫`、`组件导航守卫`，而最为常用的便是全局导航守卫中的`beforeEach`，每次界面的跳转都会经过里面的逻辑，只有通过才会进行跳转。
例如一些组件需要登陆才能进行访问，否则进入登陆或者401界面，那么用 vue-router 可以这么写：
```javascript
const router = new Router({
    mode: 'history',
    routes: baseRouter
});

router.beforeEach((to, from, next) => {
	// TODO: Landing logic
	next();
}
```
这样每次界面的跳转都会执行里面的逻辑，只有调用`next()`才能跳转，否则我们可以为其跳转到其它界面。
那么 react-router 为什么不提供相应的 api 呢？其实是因为设计理念的区别，React 会选择让用户自己封装相应的功能，路由守卫功能在很久前也被人提出了[react-router路由拦截官方说明](https://github.com/ReactTraining/react-router/issues/4962)，而作者更希望保证插件的灵活性，让用户自己封装相应代码的功能。
## 配置文件
项目中为了方便，我们要添加路由配置文件，然后根据配置文件生成路由.。
我们先定义路由数据类型：
```typescript
export interface routersProps{
	// 路径
    path: string,
    // 名称
    name: string,
    // 是否需要登陆
    auth?: boolean,
    // 是否严格验证
    exact?: boolean,
    // 组件
    component: React.FC<any>,
    // 子路由
    children?: Array<routersProps>
}
```
这样定义了一些路由的数据类型，然后我们的路由数组可以这么定义：
```typescript
const routers: Array<routersProps> = [
    {
        path: '/user',
        name: 'user',
        component: React.lazy(() => import('../layouts/UserLayout')),
        children: [
            {
                exact: true,
                name: 'userLogin',
                path: '/user/login',
                component: React.lazy(() => import('../pages/login/index')),
            }
        ]
    }, {
        path: '/',
        name: 'index',
        auth: true,
        component: React.lazy(() => import('../layouts/BasicLayout')),
        children: [
            {
                exact: true,
                name: 'Article',
                path: '/article',
                component: React.lazy(() => import('../pages/article/index')),
            }
        ]
    }
]
```
这样简单的定义了一些路由数组，其组件使用了`React.lazy`主要为了让组件使用的时候再去加载。
## 遍历路由
既然组件已经定义完成了，下面我们需要根据配置文件遍历出组件，我们可以这样去封装组件的遍历：
```javascript
interface RenderRoutesProps{
    routes: Array<routersProps>
}

const RenderRoutesMap: React.FC<RenderRoutesProps> = ({ routes }) => {
    return (
        <Switch>
            {
                routes.map((route, index) => {
                    return (
                        <Route key={index} path={route.path} render={props => (
                            <RouterGuard router={route} routerProps={props} />
                        )} />
                    )
                })
            }
        </Switch>
    )
}

export default RenderRoutesMap;
```
这样组件`RenderRoutesMap`接收一个路由数组，但是我们并没有着急使用`Route`渲染，而是引入了另一个组件`RouterGuard`，并传入了 route(当前路由信息)、props(react-router) 作为参数。
## HOC封装
组件逻辑的判断因为需要被大量的组件使用，所以为了代码更好的复用这里使用 HOC，封装组件真正的展示：
```typescript
interface RouterGuardProps {
    router: routersProps,
    routerProps: RouteComponentProps,
}

const RouterGuard: React.FC<RouterGuardProps> = ({router, routerProps}) => {
    const { name, path, exact, auth, children = []} = router;
    return (
        <Route name={name} path={path} key={path} exact={exact} render={() => {
            return <Suspense fallback={<div>loading....</div>}>
                <router.component {...routerProps}>
                    <RenderRoutesMap routes={children} />
                </router.component>
            </Suspense>
        }} />
    )
}
export default RouterGuard;
```
首先对组件进行渲染，因为使用了`React.lazy`包装组件，所以使用的时候要加上`React.Suspense`，然后对组件内容进行递归调用，遍历组件的 children 子元素，因为可能设计到多层嵌套，这里直接把 children 传递给`RenderRoutesMap`组件，让其循环遍历即可。

### 添加逻辑处理
上面我们基本路由已经遍历处理完成，我们可以直接在`RouterGuard`封装逻辑代码，因为我们所有路由都经过了它的封装，所以进入新的界面`RouterGuard`里面的逻辑都会执行，我们可以这样去封装：
```javascript
const RouterGuard: React.FC<RouterGuardProps> = ({router, routerProps}) => {
    const { name, path, exact, auth, children = []} = router;
    const [loading, setLoading] = useState(true);
    useEffect(() => {
        if(!!auth && !localStorage.getItem('token')){
            notification.error({
                message: '令牌无效',
                description:
                'token 过期或失效，请重新登陆',
            });
            routerProps.history.replace('/user/login');
        }else{
            setLoading(false);
        }
    })
    return (
        loading?<PageLoading />:<Route .../>
    )
}

export default RouterGuard;
```
这样我们添加 loading 属性，当界面还在加载或验证逻辑的时候会显示 loading 界面，处理完成才展示 router，如果不符合逻辑使用`history.replace`进行重定向。
## 引用
上面代码已经基本封装完成，我们在使用路由时通过下面代码引用即可：
```javascript
<BrowserRouter>
  <RenderRoutesMap routes={routes} />
</BrowserRouter>
```
将路由数组传入即可完成。
## 总结
上面代码可以满足基本的导航守卫的封装，但是代码还是有很多需要改进的地方，这里就先抛砖引玉了。如果需要实现较为好用的权限路由可以使用 [umi路由](https://umijs.org/)，其内置了许多权限和路由相关的封装。