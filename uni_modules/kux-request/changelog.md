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
