#import <objc/runtime.h>
#import "JastorRuntimeHelper.h"

static const char *property_getTypeName(objc_property_t property) {
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		if (attribute[0] == 'T') {
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
		}
	}
	return "@";
}

@implementation JastorRuntimeHelper

static NSMutableDictionary *propertyListByClass;
static NSMutableDictionary *propertyClassByClassAndPropertyName;
+ (BOOL)isPropertyReadOnly:(Class)klass propertyName:(NSString*)propertyName{
    const char * type = property_getAttributes(class_getProperty(klass, [propertyName UTF8String]));
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
//    NSString * typeAttribute = [attributes objectAtIndex:0];
//    NSString * propertyType = [typeAttribute substringFromIndex:1];
    NSString * typeAttribute = [attributes objectAtIndex:1];

//    const char * rawPropertyType = [propertyType UTF8String];
    
    LGLOG(LGFLAG_JASTORHELPER,@"typeAttribute %@: for property: %@ for class:%@",NSStringFromClass(klass),propertyName,typeAttribute);
    return [typeAttribute rangeOfString:@"R"].length > 0;
}

+ (NSArray *)propertyNames:(Class)klass {
    if (klass == [Jastor class]) {
        return [NSArray array];
    }
	if (!propertyListByClass) {
        propertyListByClass = [[NSMutableDictionary alloc] init];
    }
	
	NSString *className = NSStringFromClass(klass);
	NSArray *value = [propertyListByClass objectForKey:className];
	
	if (value) {
		return value; 
	}
	
	NSMutableArray *propertyNamesArray = [[[NSMutableArray alloc] init] autorelease];
	unsigned int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
	for (unsigned int i = 0; i < propertyCount; ++i) {
		objc_property_t property = properties[i];
		const char * name = property_getName(property);
		
		[propertyNamesArray addObject:[NSString stringWithUTF8String:name]];
	}
	free(properties);
	
	[propertyListByClass setObject:propertyNamesArray forKey:className];
    NSArray* arr = [JastorRuntimeHelper propertyNames:class_getSuperclass(klass)];
	[propertyNamesArray addObjectsFromArray:arr];
    return propertyNamesArray;
}

+ (Class)propertyClassForPropertyName:(NSString *)propertyName ofClass:(Class)klass {
	if (!propertyClassByClassAndPropertyName) propertyClassByClassAndPropertyName = [[NSMutableDictionary alloc] init];
	
	NSString *key = [NSString stringWithFormat:@"%@:%@", NSStringFromClass(klass), propertyName];
	NSString *value = [propertyClassByClassAndPropertyName objectForKey:key];
	
	if (value) {
		return NSClassFromString(value);
	}
	
	unsigned int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
	const char * cPropertyName = [propertyName UTF8String];
	
	for (unsigned int i = 0; i < propertyCount; ++i) {
		objc_property_t property = properties[i];
		const char * name = property_getName(property);
		if (strcmp(cPropertyName, name) == 0) {
			free(properties);
			NSString *className = [NSString stringWithUTF8String:property_getTypeName(property)];
			[propertyClassByClassAndPropertyName setObject:className forKey:key];
			return NSClassFromString(className);
		}
	}
	free(properties);
	return nil;
}

@end
