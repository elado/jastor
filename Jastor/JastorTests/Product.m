#import "ProductCategory.h"
#import "Product.h"

@implementation Product

@synthesize name, category, amount, createdAt;

+(Class)skuIds_class {
    return [NSDictionary class];
}

@end
