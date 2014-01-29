#import "Person.h"

@implementation Person

@synthesize firstName, lastName;

- (void)dealloc {
	[firstName release]; firstName = nil;
	[lastName release]; lastName = nil;

	[super dealloc];
}

- (NSDictionary *)map{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[super map]];
    [map setObject:@"first_name" forKey:@"firstName"];
    [map setObject:@"last_name" forKey:@"lastName"];
    return [NSDictionary dictionaryWithDictionary:map];
}

@end
