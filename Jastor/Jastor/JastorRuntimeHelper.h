@interface JastorRuntimeHelper : NSObject {
	
}

+ (Class)propertyClassForPropertyName:(NSString *)propertyName ofClass:(Class)klass;
+ (NSArray *)propertyNames:(Class)klass;

@end
