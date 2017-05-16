//
//  MMClassInfo.m
//  PracticeKit
//
//  Created by 晓东 on 16/12/5.
//  Copyright © 2016年 Xiaodong. All rights reserved.
//

#import "MMClassInfo.h"

MMEncodingType MMEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return MMEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return MMEncodingTypeUnknown;
    
    MMEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r':{
                qualifier |= MMEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= MMEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= MMEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= MMEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= MMEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= MMEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= MMEncodingTypeQualifierOneway;
                type++;
            } break;
            default: {
                prefix = false;
            } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return MMEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return MMEncodingTypeVoid | qualifier;
        case 'B': return MMEncodingTypeBool | qualifier;
        case 'c': return MMEncodingTypeInt8 | qualifier;
        case 'C': return MMEncodingTypeUInt8 | qualifier;
        case 's': return MMEncodingTypeInt16 | qualifier;
        case 'S': return MMEncodingTypeUInt16 | qualifier;
        case 'i': return MMEncodingTypeInt32 | qualifier;
        case 'I': return MMEncodingTypeUInt32 | qualifier;
        case 'l': return MMEncodingTypeInt32 |  qualifier;
        case 'L': return MMEncodingTypeUInt32 | qualifier;
        case 'q': return MMEncodingTypeInt64 | qualifier;
        case 'Q': return MMEncodingTypeUInt64 | qualifier;
        case 'f': return MMEncodingTypeFloat | qualifier;
        case 'd': return MMEncodingTypeDouble | qualifier;
        case 'D': return MMEncodingTypeLongDouble | qualifier;
        case '#': return MMEncodingTypeClass | qualifier;
        case ':': return MMEncodingTypeSEL | qualifier;
        case '*': return MMEncodingTypeCString | qualifier;
        case '^': return MMEncodingTypePointer | qualifier;
        case '[': return MMEncodingTypeCArray | qualifier;
        case '(': return MMEncodingTypeUnion | qualifier;
            case '{': return MMEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return MMEncodingTypeBlock | qualifier;
            else
                return MMEncodingTypeObject | qualifier;
        }
        default: return MMEncodingTypeUnknown | qualifier;
    }
}

@implementation MMClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = MMEncodingGetType(typeEncoding);
    }
    return self;
}
@end

@implementation MMClassMethodInfo
- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    self = [super init];
    _method = method;
    _sel = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_sel);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypes = [NSMutableArray new];
        for (unsigned int i = 0; i < argumentCount; i++) {
            char *argumentType = method_copyArgumentType(method, i);
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncoding = argumentTypes;
    }
    return self;
}

@end

@implementation MMClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    MMEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': {
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = MMEncodingGetType(attrs[i].value);
                    
                    if ((type & MMEncodingTypeMask) == MMEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString *protocol = nil;
                            if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': {
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= MMEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= MMEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= MMEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= MMEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= MMEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= MMEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= MMEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= MMEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            }
            default: break;
        }
    }
    
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringFromIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation MMClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) _metaCls = objc_getMetaClass(class_getName(cls));
    _name = NSStringFromClass(cls);
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            MMClassMethodInfo *info = [[MMClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            MMClassPropertyInfo *info = [[MMClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            MMClassIvarInfo *info = [[MMClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    _needUpdate = NO;
}

- (void)setNeddUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    MMClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)cls);
    if (info && info->_needUpdate) {
        [info _update];
    }
    
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[MMClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)cls, (__bridge const void *)info);
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}


+ (instancetype)classInfoWitClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}




@end
