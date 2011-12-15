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

//static NSMutableDictionary *lookupTableByClass;

// TODO cache these, even on device!

+ (NSArray *)propertyNames:(Class)klass {
	//	if (!lookupTableByClass) lookupTableByClass = [NSMutableDictionary dictionary];
	//	
	//	NSString *className = NSStringFromClass(klass);
	//	NSArray *value = [lookupTableByClass valueForKey:className];
	//	
	//	if (value) {
	//		return value; 
	//	}
	
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
		
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
	
	//	[lookupTableByClass setObject:[propertyNames retain] forKey:className];
	
	//    return propertyNames; //[propertyNames autorelease];
    return [propertyNames autorelease];
}

+ (Class)propertyClassForPropertyName:(NSString *)propertyName ofClass:(Class)klass {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
	const char * cPropertyName = [propertyName UTF8String];
	
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
		if (strcmp(cPropertyName, name) == 0) {
			free(properties);
			NSString *className = [NSString stringWithUTF8String:property_getTypeName(property)];
			return NSClassFromString(className);
		}
    }
    free(properties);
	return nil;
}

@end
