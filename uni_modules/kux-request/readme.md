# kux-request
`kux-request` 是一个基于 `uni.request` 的一个简洁高效的`uts`请求库，支持请求同步/异步拦截、请求重试、请求过滤等丰富功能，提供人性化的请求配置，旨在帮助`uniapp x`开发者专注业务开发，提升业务开发效率。

## 插件特色
+ 请求同步拦截
+ 请求过滤
+ 请求缓存
+ 批量请求
+ 请求重试【基于指数退避算法】
+ 中断请求
+ 人性化的请求配置
+ 组合式API

## 目录结构
<div style="list-style-type: none;">
	<ol style="list-style-type: none;">
		<li><a href="#guide">基础</a>
			<ol>
				<li><a href="#guide_installation">安装配置</a></li>
				<li><a href="#guide_guide">入门使用</a></li>
			</ol>
		</li>
		<li><a href="#advanced">进阶</a>
			<ol>
				<li><a href="#advanced_interceptor">请求/响应拦截</a>
					<ol>
						<li><a href="#advanced_interceptor_play">项目集成示例</a></li>
					</ol>
				</li>
				<li><a href="#advanced_filter">请求过滤</a></li>
				<li><a href="#advanced_retry">请求重试</a></li>
				<li><a href="#advanced_batch">批量请求</a></li>
				<li><a href="#advanced_abort">中断请求</a></li>
				<li><a href="#advanced_config">请求配置</a></li>
				<li><a href="#advanced_unierror">错误码规范</a></li>
			</ol>
		</li>
		<li><a href="#api">API</a>
			<ol>
				<li><a href="#api_get">get</a></li>
				<li><a href="#api_post">post</a></li>
				<li><a href="#api_put">put</a></li>
				<li><a href="#api_delete">delete</a></li>
				<li><a href="#api_request">request</a></li>
				<li><a href="#api_getKey">getKey</a></li>
				<li><a href="#api_cache">cache</a></li>
				<li><a href="#api_clearCache">clearCache</a></li>
				<li><a href="#api_abort">abort</a></li>
				<li><a href="#api_overrideConfig">overrideConfig</a></li>
				<li><a href="#api_onFail">onFail</a></li>
			</ol>
		</li>
		<li><a href="#use">组合式API</a>
			<ol>
				<li><a href="#use_useRequest">useRequest</a></li>
				<li><a href="#use_useInterceptor">useInterceptor</a></li>
				<li><a href="#use_useFilter">useFilter</a></li>
				<li><a href="#use_useURL">useURL</a></li>
				<li><a href="#use_useUtils">useUtils</a></li>
				<li><a href="#use_useRetry">useRetry</a></li>
				<li><a href="#use_useBatchRequest">useBatchRequest</a></li>
			</ol>
		</li>
		<li><a href="#type">自定义type</a>
			<ol>
				<li><a href="#type_UseOptions">UseOptions</a></li>
				<li><a href="#type_RequestConfig">RequestConfig</a></li>
				<li><a href="#type_RequestInterceptor">RequestInterceptor</a></li>
				<li><a href="#type_RequestInterceptorSync">RequestInterceptorSync</a></li>
				<li><a href="#type_ResponseInterceptor">ResponseInterceptor</a></li>
				<li><a href="#type_ResponseInterceptorSync">ResponseInterceptorSync</a></li>
				<li><a href="#type_Interceptors">Interceptors</a></li>
				<li><a href="#type_FilterOptions">FilterOptions</a></li>
				<li><a href="#type_PendingRequests">PendingRequests</a></li>
				<li><a href="#type_UseRetryOptions">UseRetryOptions</a></li>
				<li><a href="#type_KuxErrorCode">KuxErrorCode</a></li>
				<li><a href="#type_KuxRequestFail">KuxRequestFail</a></li>
				<li><a href="#type_RequestFailCallback">RequestFailCallback</a></li>
			</ol>
		</li>
	</ol>
</div>

<a id="guide"></a>
## 基础

<a id="guide_installation"></a>
### 安装配置
本插件为完全的 `uni_modules` 插件，所以直接在 [插件市场](https://ext.dcloud.net.cn) 搜索 `kux-request` 安装即可。

<a id="guide_guide"></a>
### 入门使用
请求库挂载方式可以自己灵活实现，下面以`模块引用`作为演示说明。
> **注意**<br/>
> 由于目前uts不支持把插件库的类型导出给外部模块之间共享使用，所以在调用请求库具体 API 时还需要手动导入插件库的类型使用，示例：<br>
> 
> ```uts
> import { RequestConfig } from '@/uni_modules/kux-request';
> ```

#### 模块引用
+ **创建 `http` 目录，位置如：`/utils/http`**<br/>

	> #### 提示
	1.该目录一般存储请求库相关的文件，比如初始化文件。<br>
	2.目录名称和创建位置可以自定义。
+ **创建 `/utils/http/index.uts` ，并初始化**

	```uts
	import { useRequest, UseOptions } from '@/uni_modules/kux-request';
	
	export const http = useRequest({
		baseURL: '', // 这里填写自己的请求域名
	} as UseOptions);
	```
+ **调用示例，这里演示 `页面直接引入使用` 和 `API调用` 两种方式**
	+ ***页面直接引入使用***
	
		```uts
		import { http } from '@/utils/http/index';
		
		http.get('/user/list').then(res => {
			console.log(res);
		})
		```
	+ ***API调用【强烈推荐】***<br>
	在调用流程中增加 `api` 层，用来管理所有的`api连接`和参数设置信息，具体如下：
		+ 创建 `api` 目录，位置如：`/utils/api`
		
		> 提示<br>
		1、该目录一般存储后端 api 调用初始化文件。<br>
		2、目录名称和创建位置可以自定义。
		
		+ 创建 api 模块，如 `/utils/api/user.uts`，并初始化
		
			```uts
			/**
			* 用户模块接口管理
			*/
			import { http } from '../http';
			// 这里的类型需要从请求库里面导入使用，因为目前 uts 不支持插件导出的类型在外部模块之间共享。。。
			import { RequestConfig } from '@/uni_modules/kux-request';
			
			interface IUser {
				info(id: number, options: RequestConfig): Promise<any>;
			};
			
			class User implements IUser {
				info(id: number, options: RequestConfig): Promise<any> {
					return http.get(`/user/detail/${id}`, options);
				}
			};
			
			export const useUser = (): User => {
				return new User();
			}
			```
			
		+ 页面直接引入使用
		
			```uts
			import { useUser } from '@/utils/api/user';
			import { RequestConfig } from '@/uni_modules/kux-request';
			
			useUser().info(1, {} as RequestConfig).then((res) => {
				console.log(res);
			}).catch((err) => {
				console.log(err);
			})
			```
		> **提示**<br/>
		> 由于 uts 全局挂载请求库使用会有类型解析问题，所以目前不支持全局挂载使用
			
#### 全局挂载【由于uts编译器泛型解析问题，目前全局挂载不可用】
##### `main.uts` 全局挂载
下载该 `uni_modules` 插件到自己的项目中后，可以直接在项目根目录的 `main.uts` 进行全局引入挂载，方便后面直接调用，示例代码如下：<br/>

```uts
import App from './App.uvue';

import { createSSRApp } from 'vue';
// 引入 kux-request 请求库
import {useRequest, UseOptions} from '@/uni_modules/kux-request';

export function createApp() {
	const app = createSSRApp(App);
	// 通过 app.use 全局挂载请求库，这里建议使用有意义的且不容易和全局内置变量冲突的名字
	// 请求配置可以放到单独的模块中方便管理	
	app.config.globalProperties.kuxRequest = useRequest({
		baseURL: '', // 这里填写自己的请求域名，建议提供 `env` 全局管理
	} as UseOptions);
	return {
		app
	}
}
```
>为了方便统一话术，上面的 `kuxRequest` 在下文中统称为 `request`

##### 页面发起请求
```uts
this.kuxRequest.get('/user/list')
	.then((res) => {
		// 获取请求结果
		console.log(res);
	})
	.catch((err) => {
		// 获取异常
		console.log(err);
	})
```

<a id="advanced"></a>
## 进阶

<a id="advanced_interceptor"></a>
### 请求/响应拦截
请求库提供了 `useInterceptor`拦截管理器来完成请求/响应拦截场景，其中请求拦截支持 `同步拦截` 和 `异步拦截`，你可以用拦截管理器来实现如下场景<br>

+ 设置请求 `header` 
+ 获取请求 `token`
+ 刷新请求 `token`
+ 修改请求参数

#### 示例代码
```uts
import { useInterceptor, RequestConfig } from '@/uni_modules/kux-request';

const interceptor = useInterceptor();
interceptor
		.useRequestSync(async (options): Promise<RequestConfig> => {
			console.log('同步请求拦截', options);
			options.data = {
				a: 2
			};
			return options;
		})
		.useRequest((options): RequestConfig => {
			console.log('请求拦截', options);
			options.data = {
				a: 1
			}
			return options;
		})
		.useResponse((res): any => {
			if (typeof res === 'object') {
				console.log('响应拦截', (res as UTSJSONObject).getAny('route'));
				res.set('route', '/a/b/c');
			}
			
			if (typeof res === 'string') {
				res = '拦截成功了';
			}
			
			return res;
		})
		.useResponseXhr((res: RequestSuccess<any>): any => {
	        console.log('原始响应拦截', res);
	        if (typeof res.data === 'object') {
	            const data = res.data as UTSJSONObject;
	            console.log(data.getAny('data'));
	        }
	        return res;
	    })
```
> **提示**
> 
> `useResponseXhr` 需要插件 `v1.0.11` 及以上版本支持。 

<a id="advanced_interceptor_play"></a>
#### 项目集成示例
+ 项目根目录新建 `utils/http/interceptors.uts` 文件来管理全局拦截器。

```
import { useInterceptor } from '@/uni_modules/kux-request';
import { RequestConfig } from '@/uni_modules/kux-request/utssdk/interface';
import { http } from './index';

const interceptors = useInterceptor();
interceptors
	.useRequestSync(async (options) : Promise<RequestConfig> => {
		console.log('同步请求拦截', options.url);
		// options.data = Object.assign(options.data ?? {}, {
		// 	a: 2
		// })
		if (options.url == '/user/create') {
			console.log('中断请求', JSON.stringify(http));
			http.abort();
		}
		return options;
	})
	.useRequest((options) : RequestConfig => {
		console.log('请求拦截', options);
		options.data = Object.assign(options.data ?? {}, {
			a: 1
		})
		return options;
	})
	.useResponse((res) : any => {
		if (typeof res === 'object') {
			console.log('响应拦截', (res as UTSJSONObject).getAny('route'));
			// (res as UTSJSONObject).set('route', '/a/b/c');
		}

		if (typeof res === 'string') {
			res = '拦截成功了';
		}

		return res;
	})
	
export default interceptors;
```
> **提示**
> 
> 上面拦截器代码为演示场景，开发者请根据自己的实际需求写自己的拦截代码。

+ 项目根目录 `main` 入口文件引入拦截器。

```
import interceptors from './utils/http/interceptors'
```

<a id="advanced_filter"></a>
### 请求过滤
请求库提供了 `useFilter` 过滤器来完成请求过滤场景，你也可以设置请求配置 `filterRequest` 参数为 `true` 实现请求过滤。
> **注意**<br/>
> 过滤器和请求配置同时开启过滤时只有过滤器会生效

#### 过滤器使用示例
```uts
import { useFilter, FilterOptinos } from '@/uni_modules/kux-request';

const filter = useFilter({
	debug: true
} as FilterOptions);

filter.filterRequest('/user/list', options, async (): Promise<any> => {
 	return request.get('/user/list?name=mary', options);
}).then((res) => {
 	console.log('请求结果', res);
});
```

#### 请求配置开启过滤使用示例
```uts
request
	.get('/user/list/?ids=2', {
		filterRequest: true, // 是否开启过滤
		debug: true
	} as RequestConfig)
	.then((res) => {
		console.log(res);
	})
```

<a id="advanced_retry"></a>
### 请求重试
请求库提供了 `useRetry` 请求重试管理器来完成请求重试场景。请求重试实例创建时需要提供三个初始化参数：<br/>

+ `maxRetryCount : number`: 最大重试次数。指定在请求失败时最多尝试多少次重试。如果请求一直失败，最多只会尝试 maxRetryCount 次重试。 ，默认为 `3`
+ `initialDelay: number `：初始重试等待时间。指定在第一次请求失败后，等待多长时间后再尝试重试。单位是毫秒。 默认为 `1000`
+ `maxDelay: number`：最大重试等待时间。指定在重试过程中，等待时间最多不超过多少毫秒。这个参数可以防止等待时间过长。 默认为 `10000`

#### 使用示例
```uts
import { useRetry } from '@/uni_modules/kux-request';

const retry = useRetry(3, 1000, 10000);
retry.sendRequest('https://test1.api.fdproxy.cn/user/list')
				.then((res) => {
					console.log(res);
				})
				.catch((err) => {
					console.log(err);
				})
```

<a id="advanced_batch"></a>
### 批量请求
请求库提供了 `useBatchRequest` 批量请求管理器来完成批量请求场景。批量请求管理器提供了 `addRequest` 逐个添加和 `addBatchRequest` 批量添加两种方式去添加请求队列。

#### 使用示例
```uts
import { useBatchRequest } from '@/uni_modules/kux-request';

async function fetchData(url: string): Promise<any> {
  // 模拟异步请求
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`Data from ${url}`);
    }, Math.random() * 1000);
  });
}

const batchManager = useBatchRequest();

// 逐个添加请求演示
// batchManager.addRequest(fetchData('https://api.example.com/data1'));
// batchManager.addRequest(fetchData('https://api.example.com/data2'));
// batchManager.addRequest(fetchData('https://api.example.com/data3'));

// 批量添加请求演示
const requests = [
	fetchData('https://api.example.com/data1'),
	fetchData('https://api.example.com/data2'),
	fetchData('https://api.example.com/data3')
];

batchManager.addBatchRequest(requests);

// 执行批量请求
async function main () {
	const results = await batchManager.executeBatch();
	
	// 处理结果
	console.log(results);
}
	
main();
```

<a id="advanced_abort"></a>
### 中断请求
请求库支持中断当前请求。其实还是 `uni.request` 的 `RequestTask` 请求任务实例的 `abort`

```uts
request().abort();
```

<a id="advanced_config"></a>
### 请求配置
请求库的请求配置分为创建请求实例时传的 `默认配置` 和 发起请求时传的 `请求配置`。`请求配置` 会覆盖 `默认配置` 的同名参数值。

#### 默认配置
##### baseURL
+ 描述：接口服务器域名，建议通过 `.env` 统一管理。
+ 类型：`string`
+ 默认值：`''`
+ 是否必填：`是`

##### query
+ 描述：请求的query参数，即最后拼接在地址栏后面的参数，如：`/user/info?id=1`
+ 类型：`UTSJSONObject | null`
+ 默认值：`null`
+ 是否必填：`否`

#### data
+ 描述：请求的data参数
+ 类型：`RequestDataOptions`
+ 默认值：`null`
+ 是否必填：`否`

#### header
+ 描述：设置请求的 header，header 中不能设置 Referer
+ 类型：`UTSJSONObject | null`
+ 默认值：`null`
+ 是否必填：`否`

#### timeout
+ 描述：超时时间，单位 `ms`
+ 类型：`number | null`
+ 默认值：`60000`
+ 是否必填：`否`

#### dataType
+ 描述：如果设为 json，会对返回的数据进行一次 JSON.parse，非 json 不会进行 JSON.parse
+ 类型：`string | null`
+ 默认值：`json`
+ 是否必填：`否`

#### responseType
+ 描述：设置响应的数据类型。
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### sslVerify
+ 描述：验证 ssl 证书
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### withCredentials
+ 描述：跨域请求时是否携带凭证（cookies）
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### firstIpv4
+ 描述：DNS解析时优先使用ipv4
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### filterRequest
+ 描述：过滤重复请求
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### debug
+ 描述：开启 debug 模式
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### xhrCode
+ 描述：响应自定义成功状态码，只有响应的自定义成功状态码匹配时才会返回响应结果
+ 类型：`any | null`
+ 默认值：`null`
+ 是否必填：`否`

#### xhrCodeName
+ 描述：响应自定义状态码字段名，成功响应的自定义状态码名称，比如 code, statusCode等
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### xhrMessageName
+ 描述：响应自定义描述内容字段名，成功响应的自定义描述内容字段名，比如 msg, message 等<br/>
	+ 在定义了 `xhrCode` 和 `xhrCodeName` 时，该参数有效，当自定义成功状态码不匹配时作为catch返回的描述语
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### openCache
+ 描述：开启请求缓存
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### maxCacheSize
+ 描述：最大缓存数量
	+ 开启请求缓存时有效
+ 类型：`number | null`
+ 默认值：`10`
+ 是否必填：`否`

#### 发起请求配置
##### url
+ 描述：接口地址
+ 类型：`string`
+ 默认值：`''`
+ 是否必填：`是`

##### query
+ 描述：请求的query参数，即最后拼接在地址栏后面的参数，如：`/user/info?id=1`
+ 类型：`UTSJSONObject | null`
+ 默认值：`null`
+ 是否必填：`否`

#### data
+ 描述：请求的data参数
+ 类型：`RequestDataOptions`
+ 默认值：`null`
+ 是否必填：`否`

#### header
+ 描述：设置请求的 header，header 中不能设置 Referer
+ 类型：`UTSJSONObject | null`
+ 默认值：`null`
+ 是否必填：`否`

#### timeout
+ 描述：超时时间，单位 `ms`
+ 类型：`number | null`
+ 默认值：`60000`
+ 是否必填：`否`

#### dataType
+ 描述：如果设为 json，会对返回的数据进行一次 JSON.parse，非 json 不会进行 JSON.parse
+ 类型：`string | null`
+ 默认值：`json`
+ 是否必填：`否`

#### responseType
+ 描述：设置响应的数据类型。
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### sslVerify
+ 描述：验证 ssl 证书
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### withCredentials
+ 描述：跨域请求时是否携带凭证（cookies）
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### firstIpv4
+ 描述：DNS解析时优先使用ipv4
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### filterRequest
+ 描述：过滤重复请求
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### debug
+ 描述：开启 debug 模式
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### xhrCode
+ 描述：响应自定义成功状态码，只有响应的自定义成功状态码匹配时才会返回响应结果
+ 类型：`any | null`
+ 默认值：`null`
+ 是否必填：`否`

#### xhrCodeName
+ 描述：响应自定义状态码字段名，成功响应的自定义状态码名称，比如 code, statusCode等
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### xhrMessageName
+ 描述：响应自定义描述内容字段名，成功响应的自定义描述内容字段名，比如 msg, message 等<br/>
	+ 在定义了 `xhrCode` 和 `xhrCodeName` 时，该参数有效，当自定义成功状态码不匹配时作为catch返回的描述语
+ 类型：`string | null`
+ 默认值：`null`
+ 是否必填：`否`

#### openCache
+ 描述：开启请求缓存
+ 类型：`boolean | null`
+ 默认值：`false`
+ 是否必填：`否`

#### maxCacheSize
+ 描述：最大缓存数量
	+ 开启请求缓存时有效
+ 类型：`number | null`
+ 默认值：`10`
+ 是否必填：`否`

#### xhrResponse
+ 描述：是否直接返回原始响应内容
	+ `v1.0.8` 及以上版本支持
+ 类型：`boolean`
+ 默认值：`false`
+ 是否必填：`否`
+ 示例代码

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

#### customData
+ 描述：自定义参数
	+ `v1.0.15` 及以上版本支持
+ 类型：`any`
+ 默认值：`null`
+ 是否必填：`否`

#### needRequestInterceptor
+ 描述：是否需要请求拦截，设置为 `false` 时，将不再加入全局请求拦截器。
	+ `v1.0.16` 及以上版本支持
+ 类型：`boolean`
+ 默认值：`true`
+ 是否必填：`否`

#### needResponseInterceptor
+ 描述：是否需要响应拦截，设置为 `false` 时，将不再加入全局响应拦截器。
	+ `v1.0.16` 及以上版本支持
+ 类型：`boolean`
+ 默认值：`true`
+ 是否必填：`否`

<a id="advanced_unierror"></a>
### 错误码规范
错误码规范是完全遵循 [uni错误规范](https://uniapp.dcloud.net.cn/tutorial/err-spec.html) 设计。具体错误码格式定义如下：

`90` + `模块代码` + `错误码`，其中目前 `模块代码` 定义如下：

| 模块代码 | 使用场景 |
| --- | --- |
| `0` | 请求库内部模块 |
| `1` | 请求库外部模块 |

完整错误码定义如下：

| 错误码 | 错误描述 |
| --- | --- |
| `901404 ` | 请求任务不存在 |
| `900408` | 请求超时 |
| `900500` | 请求失败 |


<a id="api"></a>
## API

<a id="api_get"></a>
### get
get请求，支持 `query传参` 和 `地址栏传参`，见下方使用示例。

#### 地址栏传参
参数直接拼接在接口地址后面即可

```uts
request.get('/user/info?id=1')
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((res) => {
		// 此处仅为演示
		console.error('请求服务异常');	
	});
```

#### query传参
可以在请求配置里面传 `query` 参数，参数类型为 `UTSJSONObject`
> **提示**<br/>
> 请求库会自动转为 `query string` 形式拼接在 `地址栏传参`后面

```uts
request.get('/user/info', {
	query: {
		id: 1
	}
} as RequestConfig)
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((err) => {
		// 此处仅为演示
		console.error('请求服务异常');
	});
```

<a id="api_post"></a>
### post
post请求方法

```uts
request.post('/user/save', {
	data: {
		user_id: 1
	}
} as RequestConfig)
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((err) => {
		// 此处仅为演示
		console.error('请求服务异常');
	});
```

<a id="api_put"></a>
### put
put请求方法

```uts
request.put('/user/edit', {
	data: {
		user_id: 1
	}
} as RequestConfig)
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((err) => {
		// 此处仅为演示
		console.error('请求服务异常');
	});
```

<a id="api_delete"></a>
### delete
delete请求方法，传参方式同 `get` 请求。

```uts
request.put('/user/edit', {
	query: {
		user_id: 1
	}
} as RequestConfig)
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((err) => {
		// 此处仅为演示
		console.error('请求服务异常');
	});
```

<a id="api_request"></a>
### request
request请求方法，可以通过 `method ` 请求参数指定请求方式。

```uts
request.request('/user/info', {
	method: 'GET'
} as RequestConfig)
	.then((res) => {
		// 此处可自定义业务逻辑
	})
	.catch((err) => {
		// 此处仅为演示
		console.error('请求服务异常');
	});
```

<a id="api_getKey"></a>
### getKey
用来获取当前请求的 `key` 标识，通过 `url` 参数和 `options` 请求配置拼接而成的字符串。定义如下：

`${url}-${JSON.stringify(options)}`

<a id="api_cache"></a>
### cache
获取指定key的请求缓存结果。key默认为 `url`-`options`

```uts
request
	.cache()
	.get('/user/list?ids=2')
	.then((res) => {
		console.log('请求结果2', res);
	})
	.catch((err) => {
		console.log('请求失败2', err);
	})
```
> **注意**<br/>
> 需要在 `openCache` 为 `true` 时才生效

<a id="api_overrideConfig"></a>
### overrideConfig
复写当前实例的全局配置，比如`data`，`query`，`header`等参数

```uts
request
	.overrideConfig({
		query: {}
	} as RequestConfig)
	.post('/user/create', {
		data: {
			name: 'Tom',
			age: 21
		}
	} as RequestConfig)
```
> **提示**
> 
> 目前仅 `baseURL`、`query`、`data` 和 `header` 设置生效。

<a id="api_clearCache"></a>
### clearCache
清除指定key的请求缓存。如果key为空则清空当前请求实例所有的请求缓存。

<a id="api_abort"></a>
### abort
中断当前请求。

<a id="api_onFail"></a>
#### onFail
捕获全局请求失败的错误信息。

```
request.onFail((fail: RequestFail) => {
	console.log('请求失败拦截', fail);
});
```
> **提示**
> 
> `v1.0.10` 及以上版本支持

<a href="use"></a>
## 组合式API

<a id="use_useRequest"></a>
### useRequest
用来创建管理 `request` 实例。

#### 属性
##### requestTask
+ 描述：获取当前请求任务。
+ 类型：`RequestTask | null`。

##### beforeSendOptions
+ 描述：获取发起请求前的请求配置。
+ 类型：`RequestConfig | null`

#### 方法
同 [API](#api)。

<a id="use_useInterceptor"></a>
### useInterceptor
用来创建和管理 [拦截器](#advanced_interceptor) 实例。

#### 属性
无

#### 方法
##### useRequest
`useRequest(interceptor: RequestInterceptor): InterceptorManager`

请求异步拦截。参考 [请求/响应拦截](#advanced_interceptor)。

##### useRequestSync
`useRequestSync(interceptor: RequestInterceptorSync): InterceptorManager`

请求同步拦截。参考 [请求/响应拦截](#advanced_interceptor)。

##### useResponse
`useResponse(interceptor: ResponseInterceptor): InterceptorManager`

响应拦截。参考 [请求/响应拦截](#advanced_interceptor)。
> **提示**<br/>
> 暂不支持同步响应拦截。

##### useResponseXhr
`useResponseXhr (interceptor: KuxRequest.ResponseXhrInterceptor): InterceptorManager`

原始响应拦截。回调函数返回的参数为 `uni.request` 成功回调的 `res` 值。
> **提示**
> 
> + `v1.0.11` 及以上版本支持
> + 使用该拦截器后会和 `useResponse` 冲突，所以两个拦截器一次只能使用一个，不然会使应用闪退，该问题在 `v1.0.11` 及以后版本修复。

```
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

<a id="use_useFilter"></a>
### useFilter
用来创建和管理 [过滤器](#advanced_filter) 实例。

#### 属性
无

#### 方法
##### filterRequest
`filterRequest(url: string, options: RequestConfig = {} as RequestConfig, request: () => Promise<any>): Promise<any>`

发起请求。

<a id="use_useURL"></a>
### useURL
方便操作地址栏参数处理。同 js 的 `URL` 类。

#### 属性
##### protocol
+ 描述：请求协议，即 `http` 或 `https`
+ 类型：`string`

##### host
+ 描述：请求域名
+ 类型：`string`

##### pathname
+ 描述：接口地址，如：`/user/info`
+ 类型：`string`

##### search
+ 描述：地址栏参数字符串，如：`?id=1&name=bob`
+ 类型：`string`

##### searchParams
+ 描述：地址栏参数集合，如：`{id: 1, name: bob}`
	+ 可以通过参数内置的`get`方法获取具体参数值，如：`searchParams.get('name')`
+ 类型：`URLSearchParams`

#### 方法
##### href
`href(): string`

获取完整的请求地址，如：`https://test.api.fdproxy.cn/user/info?id=1&name=bob`

#### 使用示例

```uts
try {
	const url = useURL('https://test.api.fdproxy.cn/user/info?id=1&name=bob');
	console.log(url.protocol);
	console.log(url.host);
	console.log(url.pathname);
	console.log(url.search);
	console.log(url.searchParams.get('id'));
	console.log(url.searchParams.get('name'));
} catch (e) {
	console.log(e);
}
```

<a id="use_useUtils"></a>
### useUtils
创建和管理工具库实例。

#### 属性
无

#### 方法
##### objToQueryString
`objToQueryString (queryObj: UTSJSONObject): string`

对象转查询字符串。

```uts
const utils = useUtils();
console.log(utils.objToQueryString({
	a: 1,
	b: 2
})); // 输出 a=1&b=2
```

##### sleep
`sleep (ms: number): Promise<any>`

程序暂停几秒。

<a id="use_useRetry"></a>
### useRetry
创建和管理 [请求重试](#advanced_retry) 实例。
#### 属性
无

#### 方法
##### sendRequest
`sendRequest (url: string, options: RequestConfig = {} as RequestConfig): Promise<any>`

发起请求方法。
> **注意**<br/>
> 请求配置是不会继承 `request` 请求实例的请求配置，发起请求时需要完整的请求地址和请求配置信息。

<a id="use_useBatchRequest"></a>
### useBatchRequest
创建和管理 [批量请求](#advanced_batch) 实例。

#### 属性
无

#### 方法
##### addRequest
`addRequest (request: Promise<any>): Promise<any>`

逐个添加请求队列。

##### addBatchRequest
`addBatchRequest (requests: Promise<any>[]): Promise<any>[]`

批量添加请求队列。

##### executeBatch
`async executeBatch (): Promise<any[]>`

执行批量请求。

<a id="type"></a>
## 自定义type
由于 [uts](https://doc.dcloud.net.cn/uni-app-x/uts/) 强类型语言原因，所以请求库的自定义类型提供给开发者根据实际情况灵活引用。
<a id="type_UseOptions"></a>
### UseOptions

```uts
export type UseOptions = {
	/**
	 * 开发者服务器域名
	 */
	baseURL: string;
	/**
	 * 请求的query参数，即最后拼接在地址栏后面的参数，如：`/user/info?id=1`
	 * @defaultValue null
	 */
	query?: UTSJSONObject | null,
	/**
	 * 请求的参数 UTSJSONObject|string类型
	 * @type {RequestDataOptions}
	 * @defaultValue null
	 */
	data?: any | null,
	/**
	 * 设置请求的 header，header 中不能设置 Referer
	 * @defaultValue null
	 */
	header?: UTSJSONObject | null,
	/**
	 * 超时时间，单位 ms
	 * @defaultValue 60000
	 */
	timeout?: number | null;
	/**
	 * 如果设为 json，会对返回的数据进行一次 JSON.parse，非 json 不会进行 JSON.parse
	 * @defaultValue "json"
	 * @deprecated 不支持
	 * @autodoc false
	 */
	dataType?: string | null;
	/**
	 * 设置响应的数据类型。
	 * 
	 * @deprecated 不支持
	 * @autodoc false
	 */
	responseType?: string | null;
	/**
	 * 验证 ssl 证书
	 * 
	 * @deprecated 不支持
	 * @autodoc false
	 */
	sslVerify?: boolean | null,
	/**
	 * 跨域请求时是否携带凭证（cookies）
	 * 
	 * @uniPlatform {
	 *    "app": {
	 *        "android": {
	 *            "osVer": "4.4",
	 *  		  	 "uniVer": "√",
	 * 			 "unixVer": "x"
	 *        },
	 *        "ios": {
	 *            "osVer": "9.0",
	 *  		  	 "uniVer": "√",
	 * 			 "unixVer": "x"
	 *        }
	 *    }
	 * }
	 * 
	 */
	withCredentials?: boolean | null,
	/**
	 * DNS解析时优先使用ipv4
	 * @defaultValue false
	 */
	firstIpv4?: boolean | null,
	/**
	 * 过滤重复请求
	 * @defaultValue false
	 */
	filterRequest?: boolean | null,
	/**
	 * 开启 debug 模式
	 * @defaultValue false
	 */
	debug?: boolean | null,
	/**
	 * 响应自定义成功状态码
	 * @description 只有响应的自定义成功状态码匹配时才会返回响应结果
	 */
	xhrCode?: any | null,
	/**
	 * 响应自定义状态码字段名
	 * @description 成功响应的自定义状态码名称，比如 code, statusCode等
	 */
	xhrCodeName?: string | null,
	/**
	 * 响应自定义描述内容字段名
	 * @description 成功响应的自定义描述内容字段名，比如 msg, message 等
	 * + 在定义了 `xhrCode` 和 `xhrCodeName` 时，该参数有效，当自定义成功状态码不匹配时作为catch返回的描述语
	 */
	xhrMessageName?: string | null,
	/**
	 * 开启请求缓存
	 */
	openCache?: boolean | null,
	/**
	 * 最大缓存数量
	 * @description 开启请求缓存时有效
	 */
	maxCacheSize?: number | null
	/**
	 * 是否直接返回原始响应内容
	 * + `v1.0.8` 及以上版本支持
	 */
	xhrResponse?: boolean
};
```

<a id="type_RequestConfig"></a>
### RequestConfig

```uts
export type RequestConfig = {
	/**
	 * 开发者服务器域名
	 */
	baseURL?: string,
	/**
	 * 开发者服务器接口地址
	 */
	url?: string,
	/**
	 * 请求的query参数，即最后拼接在地址栏后面的参数，如：`/user/info?id=1`
	 * @defaultValue null
	 */
	query?: UTSJSONObject | null,
	/**
	 * 请求的参数 UTSJSONObject|string类型
	 * @type {RequestDataOptions}
	 * @defaultValue null
	 */
	data?: any | null,
	/**
	 * 设置请求的 header，header 中不能设置 Referer
	 * @defaultValue null
	 */
	header?: UTSJSONObject | null,
	/**
	 * 请求方法
	 * 如果设置的值不在取值范围内，会以GET方法进行请求。
	 * @type {RequestMethod}
	 * @defaultValue "GET"
	 */
	method?: RequestMethod | null;
	/**
	 * 超时时间，单位 ms
	 * @defaultValue 60000
	 */
	timeout?: number | null;
	/**
	 * 如果设为 json，会对返回的数据进行一次 JSON.parse，非 json 不会进行 JSON.parse
	 * @defaultValue "json"
	 * @deprecated 不支持
	 * @autodoc false
	 */
	dataType?: string | null;
	/**
	 * 设置响应的数据类型。
	 * 
	 * @deprecated 不支持
	 * @autodoc false
	 */
	responseType?: string | null;
	/**
	 * 验证 ssl 证书
	 * 
	 * @deprecated 不支持
	 * @autodoc false
	 */
	sslVerify?: boolean | null,
	/**
	 * 跨域请求时是否携带凭证（cookies）
	 * 
	 * @uniPlatform {
	 *    "app": {
	 *        "android": {
	 *            "osVer": "4.4",
	 *  		  	 "uniVer": "√",
	 * 			 "unixVer": "x"
	 *        },
	 *        "ios": {
	 *            "osVer": "9.0",
	 *  		  	 "uniVer": "√",
	 * 			 "unixVer": "x"
	 *        }
	 *    }
	 * }
	 * 
	 */
	withCredentials?: boolean | null,
	/**
	 * DNS解析时优先使用ipv4
	 * @defaultValue false
	 */
	firstIpv4?: boolean | null,
	/**
	 * 过滤重复请求
	 * @defaultValue false
	 */
	filterRequest?: boolean | null,
	/**
	 * 开启 debug 模式
	 * @defaultValue false
	 */
	debug?: boolean | null,
	/**
	 * 接口自定义成功状态码
	 * @description 只有响应的自定义成功状态码匹配时才会返回响应结果
	 */
	xhrCode?: any | null,
	/**
	 * 接口自定义状态码字段名
	 * @description 成功响应的自定义状态码名称，比如 code, statusCode等
	 */
	xhrCodeName?: string | null,
	/**
	 * 响应自定义描述内容字段名
	 * @description 成功响应的自定义描述内容字段名，比如 msg, message 等
	 * + 在定义了 `xhrCode` 和 `xhrCodeName` 时，该参数有效，当自定义成功状态码不匹配时作为catch返回的描述语
	 */
	xhrMessageName?: string | null,
	/**
	 * 开启请求缓存
	 */
	openCache?: boolean | null,
	/**
	 * 最大缓存数量
	 * @description 开启请求缓存时有效
	 * @defaultValue 10
	 */
	maxCacheSize?: number | null
	/**
	 * 是否直接返回原始响应内容
	 * + `v1.0.8` 及以上版本支持
	 */
	xhrResponse?: boolean
	/**
	 * 自定义参数
	 * + `v1.0.15` 及以上版本支持
	 */
	customData?: any | null
	/**
	 * 是否需要请求拦截，设置为 `false` 时，将不再加入全局拦截器拦截。
	 * + `v1.0.16` 及以上版本支持
	 */
	needRequestInterceptor?: boolean
	/**
	 * 是否需要响应拦截，设置为 `false` 时，将不再加入全局响应拦截。
	 * + `v1.0.16` 及以上版本支持
	 */
	needResponseInterceptor?: boolean
};
```

<a id="type_RequestInterceptor"></a>
### RequestInterceptor

```uts
export type RequestInterceptor = (options: RequestConfig) => RequestConfig;
```

<a id="type_RequestInterceptorSync"></a>
### RequestInterceptorSync

```uts
export type RequestInterceptorSync = (options: RequestConfig) => Promise<RequestConfig>;
```

<a id="type_ResponseInterceptor"></a>
### ResponseInterceptor

```uts
export type ResponseInterceptor = (response: any) => any;
```

<a id="type_ResponseInterceptorSync"></a>
### ResponseInterceptorSync

```uts
export type ResponseInterceptorSync = (response: any) => Promise<any>;
```

<a id="type_ResponseXhrInterceptor"></a>
### ResponseXhrInterceptor

```
export type ResponseXhrInterceptor = (response: RequestSuccess<any>) => any;
```
> **提示**
> 
> + `v1.0.11` 及以上版本支持
> + 使用该拦截器后会和 `useResponse` 冲突，所以两个拦截器一次只能使用一个

<a id="type_RequestFailCallback"></a>
#### RequestFailCallback

```
export type RequestFailCallback = (fail: RequestFail) => void;
```
> **提示**
> 
> `v1.0.10` 及以上版本支持

<a id="type_Interceptors"></a>
### Interceptors

```uts
export type Interceptors = {
	request: RequestInterceptor[],
	response: ResponseInterceptor[],
	requestSync?: RequestInterceptorSync | null,
	responseSync?: ResponseInterceptorSync | null
}
```

<a id="type_FilterOptions"></a>
### FilterOptions

```uts
export type FilterOptions = {
	debug?: boolean;
};
```

<a id="type_PendingRequests"></a>
### PendingRequests

```uts
export type PendingRequests = Map<string, Promise<any>>;
```

<a id="type_UseRetryOptions"></a>
### UseRetryOptions

```uts
/**
 * useRetry 初始化配置
 */
export type UseRetryOptions = {
	/**
	 * 最大重试次数
	 */
	maxRetryCount?: number | null;
	/**
	 * 初始重试等待时间
	 */
	initialDelay?: number | null;
	/**
	 * 最大重试等待时间
	 */
	maxDelay?: number | null;
};
```

<a id="type_KuxErrorCode"></a>
### KuxErrorCode

```uts
/**
 * 错误码
 * 根据uni错误码规范要求，建议错误码以90开头，以下是错误码示例：
 * - 9010001 错误信息1
 * - 9010002 错误信息2
 */
export type KuxErrorCode = 901404 | 900408 | 900500;
```

<a id="type_KuxRequestFail"></a>
### KuxRequestFail

```uts
export interface KuxRequestFail extends IUniError {
	errCode: KuxErrorCode
}
```

#### 函数和类类型签名
```
/**
 * Request实例
 */
export declare class Request {
	constructor (config: UseOptions);
	
	public getKey (url: string, options: RequestConfig): string;
	
	/**
	 * 清除指定key的请求缓存
	 * @description 请求指定key的请求缓存，如果key为空则清空当前请求实例所有的请求缓存
	 * @returns {Request}
	 */
	public clearCache (key: string): Request;
	
	/**
	 * 获取指定key的请求缓存结果
	 * @description 获取指定key的请求缓存结果
	 * + key默认为 `url`-`options`
	 * @returns {Request}
	 */
	public cache (key: string): Request;
	
	/**
	 * 复写全局配置
	 * @description 复写当前实例的全局配置，比如data，query，header参数
	 * @param {RequestConfig} config 配置项
	 * @returns {Request}
	 */
	public overrideConfig (config: RequestConfig): Request;
	
	/**
	 * request请求
	 * @param {string} url 请求地址
	 * @param {RequestConfig} options 请求配置，会覆盖全局配置
	 * @returns {Promise<any>}
	 */
	public request (url: string, options: RequestConfig): Promise<any>;
	
	/**
	 * get请求
	 * @param {string} url 请求地址
	 * @param {RequestConfig} options 请求配置，会覆盖全局配置
	 * @returns {Promise<any>}
	 */
	public get (url: string, options: RequestConfig): Promise<any>;
	
	/**
	 * post请求
	 * @param {string} url 请求地址
	 * @param {RequestConfig} options 请求配置，会覆盖全局配置
	 * @returns {Promise<any>}
	 */
	public post (url: string, options: RequestConfig): Promise<any>;
	
	/**
	 * put请求
	 * @param {string} url 请求地址
	 * @param {RequestConfig} options 请求配置，会覆盖全局配置
	 * @returns {Promise<any>}
	 */
	public put (url: string, options: RequestConfig): Promise<any>;
	
	/**
	 * delete请求
	 * @param {string} url 请求地址
	 * @param {RequestConfig} options 请求配置，会覆盖全局配置
	 * @returns {Promise<any>}
	 */
	public delete (url: string, options: RequestConfig): Promise<any>;
	
	/**
	 * 中断当前请求
	 */
	public abort (): void;
}

/**
 * 创建请求实例
 * @param {UseOptions} options 实例参数
 * @returns {Request} 返回请求实例对象
 */
export declare function useRequest (options: UseOptions): Request;


/**
 * 拦截器实例
 */
export declare class InterceptorManager {
	constructor ();
	
	/**
	 * 请求拦截
	 * @param {RequestInterceptor} 拦截器回调
	 */
	public useRequest(interceptor: RequestInterceptor): InterceptorManager;
	
	/**
	 * 同步请求拦截
	 * @param {RequestInterceptorSync} 拦截器回调
	 */
	public useRequestSync(interceptor: RequestInterceptorSync): InterceptorManager;
	
	/**
	 * 响应拦截
	 * @param {ResponseInterceptor} 拦截器回调
	 */
	public useResponse(interceptor: ResponseInterceptor): InterceptorManager;
	
	/**
	 * 原始响应拦截
	 * + `v1.0.11` 及以上版本支持。
	 * @param {ResponseXhrInterceptor} 拦截器回调
	 */
	useResponseXhr(interceptor: ResponseXhrInterceptor): IInterceptorManager;
}

/**
 * 创建拦截器实例
 * @returns {InterceptorManager} 返回拦截器实例对象
 */
export declare function useInterceptor ():  InterceptorManager;

/**
 * 过滤器实例
 */
export declare class RequestFilters {
	constructor (options?: FilterOptions);
	
	/**
	 * 请求过滤器
	 */
	public filterRequest(url: string, options: RequestConfig, request: () => Promise<any>): Promise<any>;
}

/**
 * 创建过滤器实例
 * @returns {RequestFilters} 返回过滤器实例对象
 */
export declare function useFilter(options?: FilterOptions): RequestFilters;

/**
 * URL搜索参数实例
 */
export declare class URLSearchParams {
	constructor (search: string);
	
	public get(key: string): string | null;
}

/**
 * URL实例
 */
export declare class URL {
	/**
	 * 请求协议，即 http 或 https
	 */
	public protocol: string;
	/**
	 * 请求域名
	 */
	public host: string;
	/**
	 * 接口地址，如：/user/info
	 */
	public pathname: string;
	/**
	 * 地址栏参数字符串，如：?id=1&name=bob
	 */
	public search: string;
	/**
	 * 地址栏参数集合，如：{id: 1, name: bob}
	 */
	public searchParams: URLSearchParams;
	
	constructor (url: string);
	
	/**
	 * 获取完整的请求地址，如：https://test.api.fdproxy.cn/user/info?id=1&name=bob
	 */
	public get href (): string;
}

/**
 * 创建URL实例
 * @returns {URL} 返回URL实例对象
 */
export declare function useURL (url: string): URL;

/**
 * 工具类实例
 */
export declare class Utils {
	/**
	 * 对象转查询字符串
	 * @param {UTSJSONObject} queryObj 对象
	 * @returns {string}
	 */
	public objToQueryString(queryObj: UTSJSONObject): string;
	
	/**
	 * 构建uni标准错误对象
	 * @param {string} errSubject 错误对象模块名称，如：kux-request
	 * @param {number} errCode 错误码
	 * @param {string} errMsg 错误内容
	 * @param {string} cause 源错误内容
	 * @returns {UniError} uni 统一错误对象
	 */
	public buildUniError(errSubject: string, errCode: number, errMsg: string, cause?: string): UniError;
	
	/**
	 * 程序暂停几秒。
	 * @param {number} ms 暂停的毫秒数
	 */
	public sleep(ms: number): Promise<any>;
	
	/**
	 * 两个对象深度合并
	 * @param {any} 目标对象
	 * @param {any} 源对象
	 */
	public deepMerge(target: any, source: any): any;
}

/**
 * 创建工具实例
 * @returns {Utils} 返回工具类实例对象
 */
export declare function  useUtils () : Utils;

/**
 * 重试实例
 */
export declare class RetryManager extends Request {
	constructor (maxRetryCount: number, initialDelay: number, maxDelay: number);
	
	/**
	 * 发送请求
	 * @param {string} url 完整的请求URL
	 * @param {RequestConfig} options 请求配置
	 */
	public sendRequest(url: string, options?: RequestConfig): Promise<any>;
}

/**
 * 创建请求重试实例
 * @param {number} maxRetryCount 最大重试次数。指定在请求失败时最多尝试多少次重试。如果请求一直失败，最多只会尝试 `maxRetryCount` 次重试。
 * @param {number} initialDelay 初始重试等待时间。指定在第一次请求失败后，等待多长时间后再尝试重试。单位是毫秒。
 * @param {number} maxDelay 最大重试等待时间。指定在重试过程中，等待时间最多不超过多少毫秒。这个参数可以防止等待时间过长。
 * @returns {RetryManager} 返回请求重试实例对象
 */
export declare function useRetry (maxRetryCount: number, initialDelay: number, maxDelay: number) : RetryManager;

/**
 * 批量请求实例
 */
export declare class BatchRequestManager {
	/**
	 * 逐个添加请求队列。
	 * @param {Promise<any>} request 请求队列
	 * @returns {Promise<any>} 请求队列Promise对象
	 */
	public addRequest(request: Promise<any>): Promise<any>;
	
	/**
	 * 批量添加请求队列。
	 * @param {Promise<any>[]} requests 请求队列
	 * @returns {Promise<any>[]} 请求队列Promise对象集合
	 */
	public addBatchRequest(requests: Promise<any>[]): Promise<any>[];
	
	/**
	 * 执行批量请求。
	 * @returns {Promise<any>[]} 请求队列Promise对象集合
	 */
	public executeBatch(): Promise<any[]>;
}

/**
 * 创建和管理 批量请求 实例。
 * @returns {BatchRequestManager} 返回批量请求实例对象
 */
export declare function useBatchRequest () : BatchRequestManager;
```
> **说明**
> 
> `Hbuilder X 4.0` 及以上版本支持。

---
### 结语
#### kux 不生产代码，只做代码的搬运工，致力于提供uts 的 js 生态轮子实现，欢迎各位大佬在插件市场搜索使用 kux 生态插件：[https://ext.dcloud.net.cn/search?q=kux](https://ext.dcloud.net.cn/search?q=kux)
#### QQ群：870628986 [点击加入](https://qm.qq.com/q/lJOzzu6UEw)

___
### 友情推荐
+ [TMUI4.0](https://ext.dcloud.net.cn/plugin?id=16369)：包含了核心的uts插件基类.和uvue组件库
+ [GVIM即时通讯模版](https://ext.dcloud.net.cn/plugin?id=16419)：GVIM即时通讯模版，基于uni-app x开发的一款即时通讯模版
+ [t-uvue-ui](https://ext.dcloud.net.cn/plugin?id=15571)：T-UVUE-UI是基于UNI-APP X开发的前端UI框架
+ [UxFrame 低代码高性能UI框架](https://ext.dcloud.net.cn/plugin?id=16148)：【F2图表、双滑块slider、炫酷效果tabbar、拖拽排序、日历拖拽选择、签名...】UniAppX 高质量UI库
+ [wx-ui 基于uni-app x开发的高性能混合UI库](https://ext.dcloud.net.cn/plugin?id=15579)：基于uni-app x开发的高性能混合UI库，集成 uts api 和 uts component，提供了一套完整、高效且易于使用的UI组件和API，让您以更少的时间成本，轻松完成高性能应用开发。
+ [firstui-uvue](https://ext.dcloud.net.cn/plugin?id=16294)：FirstUI（unix）组件库，一款适配 uni-app x 的轻量、简洁、高效、全面的移动端组件库。
+ [easyXUI 不仅仅是UI 更是为UniApp X设计的电商模板库](https://ext.dcloud.net.cn/plugin?id=15602)：easyX 不仅仅是UI库，更是一个轻量、可定制的UniAPP X电商业务模板库，可作为官方组件库的补充,始终坚持简单好用、易上手
+ [OneUI](https://ext.dcloud.net.cn/plugin?id=17104)：致力于提供简洁、现代的 UI 组件，帮助开发者快速构建美观、功能丰富的移动应用程序。
