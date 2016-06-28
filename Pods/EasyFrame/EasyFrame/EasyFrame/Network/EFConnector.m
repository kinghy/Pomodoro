//
//  EFConnector.m
//  EasyFrame
//
//  Created by kinghy on 15/6/7.
//  Copyright (c) 2015年 交易支点. All rights reserved.
//

#import "EFConnector.h"
#import "EFConnectorParam.h"
#import "EFEntity.h"
#import <objc/runtime.h>

@interface EFConnector()
/*!
 *  @brief  从EFConnectorParam解析请求参数
 *
 *  @param param 请求的网络链接参数
 *  @param cls   param所属的类
 *
 *  @return 返回解析后NSDictionary对象
 *
 */
-(NSDictionary*)getDictFromParam:(EFConnectorParam *)param class:(Class)cls;

/*!
 *  @brief  从json解析返回数据
 *
 *  @param json   接口返回的json数据
 *  @param entity 返回的entity（out）
 *  @param cls    Entity所属类
 *  @param aliasName 别名
 */
-(void)getEntityFromJson:(id)json entity:(EFEntity**)entity class:(Class)cls aliasName:(NSString*)aliasName;

@end

@implementation EFConnector
+(instancetype)connector{
    return [[self alloc] init];
}
-(void)run:(EFConnectorParam *)param returnBlock:(EFConnRetBlock)block{
    NSDictionary *dict =  [self getDictFromParam:param class:[param class]];
    
    NSMutableDictionary *tmpdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [tmpdict addEntriesFromDictionary:param.dict];
    dict = [NSDictionary dictionaryWithDictionary:tmpdict];
   
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = param.delayRequestTimeOut;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",nil];
    NSDictionary *dt = [param getHeaders];
    if (dt) {
        NSArray *keys = [dt allKeys];
        for (int i=0; i<keys.count; ++i) {
            [manager.requestSerializer setValue:dt[keys[i]] forHTTPHeaderField:keys[i]];
        }
    }
    
    if ([[[param getMethod] lowercaseString] isEqualToString:[kMethodGet lowercaseString]]) {
        
        [manager GET:[param getOperatorTypeTranslate] parameters:dict.count>0?dict:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self connectSuccess:task withParam:param andObj:responseObject andRetBlock:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self connectError:error withTask:task andParam:param andRetBlock:block];
        }];
        
    }else if([[[param getMethod] lowercaseString] isEqualToString:[kMethodPost lowercaseString]]){
        [manager POST:[param getOperatorTypeTranslate] parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self connectSuccess:task withParam:param andObj:responseObject andRetBlock:block];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self connectError:error withTask:task andParam:param andRetBlock:block];
        }];
    }
    
}

-(void)connectSuccess:(NSURLSessionDataTask *)task withParam:(EFConnectorParam *)param  andObj:(id)responseObject andRetBlock:(EFConnRetBlock)block{
    Class cls = [param getEntityClass];
    EFEntity* entity = nil;
    if ([cls isSubclassOfClass:[EFEntity class]]) {
        entity = [[cls alloc] init];
        if ([entity respondsToSelector:@selector(parseJson:)]) {
            responseObject = [entity parseJson:responseObject];
        }
        [self getEntityFromJson:responseObject entity:&entity class:[entity class] aliasName:[param getAliasName]];
        entity.dict = responseObject;
    }
    [param catchErrors:nil withEntity:entity];
    if(block){
        block(task,entity,nil);
    }
}

-(void)connectError:(NSError*)error withTask:(NSURLSessionDataTask *)task andParam:(EFConnectorParam *)param andRetBlock:(EFConnRetBlock)block{
    DDLogError(@"%@",error);
    [param catchErrors:error withEntity:nil];
    if(block){
        block(task,nil,error);
    }
}
//
//-(EFConnResult*)runUntilFinished:(EFConnectorParam *)param{
//    EFConnResult* result = [[EFConnResult alloc] init];
//    NSDictionary *dict =  [self getDictFromParam:param class:[param class]];
//    
//    NSMutableDictionary *tmpdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//    [tmpdict addEntriesFromDictionary:param.dict];
//    dict = [NSDictionary dictionaryWithDictionary:tmpdict];
//    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
//    requestSerializer.timeoutInterval = param.delayRequestTimeOut;
//    NSDictionary *dt = [param getHeaders];
//    if (dt) {
//        NSArray *keys = [dt allKeys];
//        for (int i=0; i<keys.count; ++i) {
//            [requestSerializer setValue:dt[keys[i]] forHTTPHeaderField:keys[i]];
//        }
//    }
//    NSMutableURLRequest *request = [requestSerializer requestWithMethod:param.getMethod URLString:param.getOperatorTypeTranslate parameters:dict.count>0?dict:nil error:nil];
//    
//    NSURLSessionTask* task = [[NSURLSessionTask alloc] ]
//    
//    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
//    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
//    
//    [requestOperation setResponseSerializer:responseSerializer];
//    [requestOperation start];
//    [requestOperation waitUntilFinished];
//    
//    if (requestOperation.error == nil) {
//        id resp = [requestOperation responseObject];
//        
//        Class cls = [param getEntityClass];
//        EFEntity* entity = nil;
//        if ([cls isSubclassOfClass:[EFEntity class]]) {
//            entity = [[cls alloc] init];
//            [self getEntityFromJson:resp entity:&entity class:[entity class] aliasName:[param getAliasName]];
//            entity.dict = resp;
//        }
//        result.operation = requestOperation;
//        result.entity = entity;
//        result.error = nil;
//        [param catchErrors:nil withEntity:entity];
//    }else{
//        result.operation = requestOperation;
//        result.entity = nil;
//        result.error = requestOperation.error;
//        [param catchErrors:result.error withEntity:nil];
//        DDLogError(@"%@",result.error);
//    }
//    return result;
//}



-(NSDictionary*)getDictFromParam:(EFConnectorParam *)param class:(Class)cls{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(cls != [EFConnectorParam class] && [cls isSubclassOfClass:[EFConnectorParam class]]){
        //定义类属性的数量
        unsigned propertyCount;
        //获取对象的全部属性并循环显示属性名称和属性特性参数
        objc_property_t *properties = class_copyPropertyList(cls,&propertyCount);
        for(int i=0;i<propertyCount;i++){
            objc_property_t prop=properties[i];
            NSString * name = [NSString stringWithFormat:@"%s",property_getName(prop)];
            @try {
                [dict setObject:[param valueForKey:name] forKey:name ];
            }
            @catch (NSException *exception) {
                
            }
            @finally{
                //                free(prop);
            }
        }
        free(properties);
        
        //迭代反射父类方法
        [dict addEntriesFromDictionary:[self getDictFromParam:param class:[cls superclass]]];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(void)getEntityFromJson:(id)json entity:(EFEntity**)entity class:(Class)cls  aliasName:(NSString*)aliasName{
    EFEntity * ent = *entity;
    if ([ent isKindOfClass:cls]) {
        if (cls != [EFEntity class]) {
            if([json isKindOfClass:[NSDictionary class]]){
                //定义类属性的数量
                unsigned propertyCount;
                //获取对象的全部属性并循环显示属性名称和属性特性参数
                objc_property_t *properties = class_copyPropertyList(cls,&propertyCount);
                for(int i=0;i<propertyCount;i++){
                    objc_property_t prop=properties[i];
                    NSString * name = [NSString stringWithFormat:@"%s",property_getName(prop)];
                    NSString * jsonName = name;
                    if ([name isEqualToString:@"ID"]) {
                        jsonName = @"id";
                    }
                    @try {
                        if ([[json objectForKey:jsonName] isKindOfClass:[NSArray class]] && aliasName) {
                            Class pkClass = NSClassFromString([NSString stringWithFormat:@"%@%@Entity",aliasName,[self makeFirstCharUppercase:name]]);
                            if (pkClass) {
                                NSMutableArray *array = [NSMutableArray array];
                                
                                NSArray *tmpArray = [json objectForKey:jsonName];
                                for (id tmp in tmpArray) {
                                    id ent = [[pkClass alloc] init];
                                    if ([ent isKindOfClass:[EFEntity class]]) {
                                        id tmpJson = tmp;
                                        if ([ent respondsToSelector:@selector(parseJson:)]) {
                                            tmpJson = [ent parseJson:tmp];
                                        }
                                        [self getEntityFromJson:tmpJson entity:&ent class:pkClass aliasName:nil];
                                        [array addObject:ent];
                                    }else{
                                        [array addObject:tmp];
                                    }
                                    
                                }
                                [ent setValue:array forKey:name];
                            }else{
                                [ent setValue:[json objectForKey:jsonName] forKey:name];
                            }
                        }else{
                            if ([json objectForKey:jsonName]) {
                                
                                NSString *tmp = [NSString stringWithFormat:@"%s",property_getAttributes(prop) ];
                                NSRange range = [tmp rangeOfString:@"NSString"];
                                if (range.location != NSIntegerMax) {
                                    [ent setValue:[NSString stringWithFormat:@"%@",[json objectForKey:jsonName]] forKey:name];
                                }else{
                                    [ent setValue:[json objectForKey:jsonName] forKey:name];
                                }
                                
                            }
                            
                        }
                    }
                    @catch (NSException *exception) {
                    }
                    @finally{
                        //                        free(prop);
                    }
                    
                }
                free(properties);
                //迭代反射父类方法
                [self getEntityFromJson:json entity:&ent class:[cls superclass] aliasName:aliasName];
            }
        }
    }
}

#pragma mark - 使字符串首字母变成大写
-(NSString*)makeFirstCharUppercase:(NSString*)str{
    if (str.length > 0) {
        NSString *firstChar = [str substringWithRange:NSMakeRange(0, 1)];
        [firstChar uppercaseString];
        return  [NSString stringWithFormat:@"%@%@",[firstChar uppercaseString],[str substringWithRange:NSMakeRange(1, str.length - 1)]] ;
    }
    return str;
}

-(void)dealloc{
    //    show_dealloc_info(self);
}
@end

//@implementation EFConnResult
//
//
//
//@end