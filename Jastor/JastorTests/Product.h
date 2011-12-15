#import "Jastor.h"

@interface Product : Jastor

@property (nonatomic, retain) ProductCategory *category;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *amount;
@property (nonatomic, copy) NSDate *createdAt;


@end
