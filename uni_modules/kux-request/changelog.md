## 1.1.2（2025-06-18）
+ 修复 `4.71` 版本编译器安卓编译失败问题。
## 1.1.1（2025-06-12）
+ 修复 `鸿蒙next` 环境响应拦截不生效的问题。
	> **注意**
	>
	> 此版本开始使用需要注意全局只有一个拦截器实例，`useResponse` 和 `useResponseXhr` 只能同时使用一个。
## 1.1.0（2025-04-03）
+ 【重要】新增支持 `鸿蒙next` 环境
	> **注意**
	>
	> `4.61` 及以上版本支持，使用需参考官方指导：[鸿蒙next平台专题指南](https://doc.dcloud.net.cn/uni-app-x/app-harmony/)
	>
	> 目前版本官方暂未支持uts插件在鸿蒙环境中调用 vue 相关API，如：`reactive`，所以插件内部是通过在 `ets` 环境基于原生 `proxy` 代理手动模拟了 `reactive` 函数行为，所以使用期间可能会有异常，如果发现相关问题请及时向我们反馈，谢谢！
## 1.0.28（2024-11-20）
+ 新增支持微信小程序环境
	> **注意**
	>
	> `4.35` 及以上版本支持，目前测试过程发现页面中不支持UTSJSONObject的实例方法，可以通过条件编译方式用对应原生语法解决
	> 该版本由于刚开通小程序环境，所以可能使用过程会有异常情况，不建议作为生产项目使用。
## 1.0.27（2024-09-24）
+ 修复调用 `abort` 中断请求后，后续请求仍然会执行的问题。
+ 优化其他已知问题。

## 1.0.26（2024-09-18）
+ 响应拦截器新增 `useResponseFail` 方法，用来支持在请求失败时手动处理响应。示例代码：

	```ts
	const interceptor = useInterceptor();
	interceptor.useResponseFail((fail, reject) => {
		console.log('响应失败拦截', fail);
		// 测试自定义抛出异常
		if (fail.errCode === 602001) {
			reject('测试异常');
		}
	});
	```
	> **注意**
	>
	> 1、响应拦截器不支持返回值
	>
	> 2、如果全局参数 `needResponseInterceptor` 设置 `false` 时，拦截器不生效
+ 优化其他已知问题。
## 1.0.25（2024-09-04）
+ 响应拦截器新增 `useResponseReject` 方法，用来支持在拦截器中手动拒绝请求。示例代码：
	
	```ts
	const interceptor = useInterceptor();
	interceptor.useResponseReject((res, reject): any => {
		console.log('响应拒绝拦截', res);
		// 测试自定义抛出异常
		if (res.statusCode === 501) {
			reject('测试异常');
		}
		return res;
	});
	```
	
+ 优化其他已知问题。
## 1.0.24（2024-08-29）
+ 修复未使用拦截器时空指针异常的问题。
+ 优化其他已知问题。

## 1.0.23（2024-08-28）
+ 修复全局 `data`、`query`、`header` 被请求的对应参数覆盖的问题。
+ 优化其他已知问题。

## 1.0.22（2024-08-27）
+ 修复 `web` 拦截器返回请求参数为 `null` 的问题。
+ 优化其他已知问题。
## 1.0.21（2024-08-23）
+ 调整类型导出方式，以此适配后面的编译器版本。
	> **注意**
	>
	> 后面版本类型导入从插件根目录导入，示例：`import { RequestConfig } from '@/uni_modules/kux-request'`
	
+ 优化其他已知问题。

## 1.0.20 (2024-08-16)
+ 修复请求拦截器中 `baseURL` 为空的问题。

## 1.0.19（2024-08-15）
+ 修复不使用拦截器请求失败的问题。
+ 修复内部工具 `useUtils` 新版本编译器部分场景使用异常的问题。
+ 修复安卓请求 `data` 传字符串时空指针异常的问题。
+ 优化其他已知问题。

## 1.0.18（2024-08-07）
+ 支持请求拦截器中修改 `baseURL`。
+ 调整 `useBatchRequest.executeBatch` 返回结果类型为 `Promise<ExecuteBatchRequestResult[]>`，以支持批量请求失败时返回失败原因。
	> **注意**
	>
	> 新的返回类型结果示例如下：
	
	```json
	[
		{
			"value": "Data from https://api.example.com/data1",
			"error": null
		},
		{
			"value": null,
			"error": "错误了"
		}
	]
	```
## 1.0.17（2024-07-16）
+ 修复一些已知问题。

## 1.0.16（2024-07-15）
+ 修复 `useRetry` 在 `web` 报URL异常问题。
+ 请求配置新增 `needRequestInterceptor` 是否需要请求拦截，设置为 `false` 时该请求不再加入全局请求拦截。
+ 请求配置新增 `needResponseInterceptor` 是否需要响应拦截，设置为 `false` 时该请求不再加入全局响应拦截。

## 1.0.15（2024-07-09）
+ 修复请求拦截修改请求地址后，请求地址不更新的问题。
+ 请求配置新增 `customData` 参数，用来自定义请求参数。

## 1.0.14（2024-06-12）
+ 修复请求参数字段值为 `null` 时报空异常的问题。

## 1.0.13（2024-04-24）
+ 修复编译到`web`、`app-ios`平台时错误输出异常问题。
+ 修复 `useRetry` 请求失败时没有抛出异常的问题。
+ 优化部分逻辑以支持后续编译器版本迭代。

## 1.0.12（2024-04-13）
+ 调整 `abort` 方法内部实现逻辑，以解决原来无法在请求拦截器中中断请求的问题。

## 1.0.11（2024-04-13）
+ `useInterceptor` 拦截器实例新增 `useResponseXhr` 拦截原始响应内容方法。

	
	```javascript
	const interceptor = useInterceptor();
	interceptor
		.useResponseXhr((res: RequestSuccess<any>): any => {
			console.log('原始响应拦截', res);
			if (typeof res.data === 'object') {
				const data = res.data as UTSJSONObject;
				console.log(data.getAny('data'));
			}
			return res;
		})
	```
## 1.0.10（2024-04-08）
+ 新增 `onFail` 全局错误捕获函数。
	
	```javascript
	request.onFail((fail: RequestFail) => {
		console.log('请求失败拦截', fail);
	});
	```
## 1.0.9（2024-04-07）
+ 调整类型签名策略，方便 `Hbuilder X版本` 向后兼容。

## 1.0.8（2024-04-01）
+ 新增 `xhrResponse` 是否直接返回原始响应内容配置参数。
	
	```
	request.post('/user/create', {
		data: {
			name: 'Tom',
			age: 24
		},
		xhrResponse: true
	} as RequestConfig)
	.then((res) => {
		console.log(res);
	})
	.catch((err) => {
		console.log(err);
	})
	```
## 1.0.7（2024-03-29）
+ 修复已知问题。

## 1.0.5（2024-03-23）
+ 修复因 `Object.assign` 官方bug导致 `data` 参数合并内容丢失的问题。
+ 补全类和函数类型签名
	> **说明**
	>
	> `HBuilderX` 版本 4.0 及以上才支持。
	
## 1.0.4（2024-03-21）
+ 修复因 `data` 传自定义类型参数导致参数丢失的问题。

## 1.0.3（2024-03-11）
+ 优化部分null异常报错问题
+ 优化编译控制台warning提示

## 1.0.2（2024-02-27）
+ 修复 因`post`请求导致的异常。
+ 新增 `overrideConfig` 方法，用来复写当前实例的全局配置。
+ 修复其他已知问题。

## 1.0.1（2024-01-29）
跟随官方4.0版本适配web（hbx4.0以上版本支持）

## 1.0.0（2024-01-04）
初始发布
