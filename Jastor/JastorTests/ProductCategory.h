#import "Jastor.h"

@interface ProductCategory : Jastor

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray *children;

@end
