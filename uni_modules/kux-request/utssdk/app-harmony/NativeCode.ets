// 1. 明确定义所有类型接口
interface EffectFunction extends Function {
    deps: Set<Set<EffectFunction>>;
    options?: EffectOptions;
}

class Effect {
    public deps: Set<Set<Effect>>;
    public options?: EffectOptions;
	private readonly fn: () => void;

    constructor(fn: () => void) {
		this.fn = fn;
		this.deps = new Set();
	}

    public run(): void {
        cleanup(this);
        activeEffect = this;
        effectStack.push(this);

        try {
            this.fn();
        } finally {
            effectStack.pop();
            activeEffect = effectStack.length > 0 ? effectStack[effectStack.length - 1] : null;
        }
    }
}

interface EffectOptions {
    lazy?: boolean;
    scheduler?: (effect: Effect) => void;
}

interface ArrayInstrumentations {
    push: <T>(arr: T[], ...items: T[]) => number;
    pop: <T>(arr: T[]) => T | undefined;
    shift: <T>(arr: T[]) => T | undefined;
    unshift: <T>(arr: T[], ...items: T[]) => number;
    splice: <T>(arr: T[], start: number, deleteCount?: number, ...items: T[]) => T[];
}

interface CustomProxyHandler<T extends object> {
    get: (target: T, key: PropertyKey) => object;
    set: (target: T, key: PropertyKey, value: object) => boolean;
}

// 2. 响应式系统核心实现
const reactiveMap = new WeakMap<object, boolean>();
const targetMap = new WeakMap<object, Map<PropertyKey, Set<Effect>>>();

let activeEffect: Effect | null = null;
const effectStack: Effect[] = [];

function createReactive<T extends object>(target: T): T {
    if (typeof target !== 'object' || target === null) return target;
    
    if (reactiveMap.has(target)) {
        return target;
    }

    const handler: CustomProxyHandler<T> = {
        get: (target: T, key: PropertyKey): object => {
            if (Array.isArray(target)) {
                const method = String(key) as keyof ArrayInstrumentations;
                switch(method) {
                    case 'push': return arrayInstrumentations.push;
                    case 'pop': return arrayInstrumentations.pop;
                    case 'shift': return arrayInstrumentations.shift;
                    case 'unshift': return arrayInstrumentations.unshift;
                    case 'splice': return arrayInstrumentations.splice;
                }
            }

            track(target, key);
            const result = Reflect.get(target, key);
            return createReactive(Object(result));
        },

        set: (target: T, key: PropertyKey, value: object): boolean => {
            const oldValue = Reflect.get(target, key);
            const reactiveValue = createReactive(value);
            const result = Reflect.set(target, key, reactiveValue);
            
            if (oldValue !== reactiveValue) {
                trigger(target, key);
            }
            return result;
        }
    };

    reactiveMap.set(target, true);
    return new Proxy(target, handler);
}

// 3. 类型安全的数组方法实现
const arrayInstrumentations: ArrayInstrumentations = {
    push: <T>(arr: T[], ...items: T[]): number => {
        const len = arr.length;
        for (let i = 0; i < items.length; i++) {
            arr[len + i] = items[i];
        }
        trigger(arr, 'length');
        return arr.length;
    },

    pop: <T>(arr: T[]): T | undefined => {
        if (arr.length === 0) return undefined;
        const value = arr[arr.length - 1];
        arr.length--;
        trigger(arr, 'length');
        return value;
    },

    shift: <T>(arr: T[]): T | undefined => {
        if (arr.length === 0) return undefined;
        const value = arr[0];
        for (let i = 1; i < arr.length; i++) {
            arr[i - 1] = arr[i];
        }
        arr.length--;
        return value;
    },

    unshift: <T>(arr: T[], ...items: T[]): number => {
        const newItems = [...items, ...arr];
        arr.length = 0;
        for (let i = 0; i < newItems.length; i++) {
            arr[i] = newItems[i];
        }
        trigger(arr, 'length');
        return arr.length;
    },

    splice: <T>(arr: T[], start: number, deleteCount: number = 0, ...items: T[]): T[] => {
        const removed = arr.slice(start, start + deleteCount);
        const newArr = [...arr.slice(0, start), ...items, ...arr.slice(start + deleteCount)];
        arr.length = 0;
        for (let i = 0; i < newArr.length; i++) {
            arr[i] = newArr[i];
        }
        trigger(arr, 'length');
        return removed;
    }
};

// 4. 依赖管理系统
const track = (target: object, key: PropertyKey): void => {
    if (!activeEffect) return;
    
    let depsMap = targetMap.get(target);
    if (!depsMap) {
        targetMap.set(target, depsMap = new Map());
    }
    
    let dep = depsMap.get(key);
    if (!dep) {
        depsMap.set(key, dep = new Set());
    }
    
    if (!dep.has(activeEffect)) {
        dep.add(activeEffect);
        activeEffect.deps.add(dep);
    }
};

const trigger = (target: object, key: PropertyKey): void => {
    const depsMap = targetMap.get(target);
    if (!depsMap) return;

    const effects = new Set<Effect>();
    const effectKeys: PropertyKey[] = [key, 'length'];
    
    effectKeys.forEach(k => {
        depsMap.get(k)?.forEach(effect => effects.add(effect));
    });

    effects.forEach(effect => {
        effect.options?.scheduler 
            ? effect.options.scheduler(effect)
            : effect.run();
    });
};

// 5. 副作用处理
const effect = (fn: () => void, options?: EffectOptions): (() => void) => {
    const effectInstance = new Effect(fn);
	
	if (options) {
		effectInstance.options = {
			lazy: options.lazy,
			scheduler: options.scheduler
		}
	}
        
	if (options?.lazy !== true) {
		effectInstance.run();
	}

	return () => cleanup(effectInstance);
};

const cleanup = (effect: Effect): void => {
    effect.deps.forEach(dep => dep.delete(effect));
    effect.deps.clear();
};

// 6. 导出函数
export const reactive = <T extends object>(target: T): T => createReactive(target);