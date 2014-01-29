//
//  JastorTests.m
//  JastorTests
//
//  Created by Elad Ossadon on 12/14/11.
//  http://devign.me | http://elad.ossadon.com | http://twitter.com/elado
//

#import "JastorTests.h"

#import "Jastor.h"
#import "ProductCategory.h"
#import "Product.h"
#import "Person.h"
#import "JSONKit.h"

@implementation JastorTests

- (void)setUp {
	[super setUp];
	
	[Jastor class];
	[Product class];
	[ProductCategory class];
	[Person class];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testDictionaryIntoObject {
	NSMutableDictionary *productDictionary = [NSMutableDictionary dictionary];
	[productDictionary setObject:@"foo" forKey:@"name"];
	
	Product *product = [[Product alloc] initWithDictionary:productDictionary];
	
	STAssertEquals(product.name, @"foo", @"name should be foo");
	
	[product release];
}

- (void)testDictionaryIntoObjectWithCustomMapping {
	NSMutableDictionary *personDictionary = [NSMutableDictionary dictionary];

	[personDictionary setObject:@"John" forKey:@"first_name"];
	[personDictionary setObject:@"Doe" forKey:@"last_name"];

	Person *person = [[Person alloc] initWithDictionary:personDictionary];

	STAssertEquals(person.firstName, @"John", @"first name should be John");
	STAssertEquals(person.lastName, @"Doe", @"last name should be Doe");

	[person release];
}

- (void)testDictionaryWithDifferentTypesIntoObject {
	NSMutableDictionary *productDictionary = [NSMutableDictionary dictionary];
	NSDate *date = [NSDate date];
	[productDictionary setObject:date forKey:@"createdAt"];
	[productDictionary setObject:[NSNumber numberWithInt:13] forKey:@"amount"];
	[productDictionary setObject:@[@"sku102",@(99),@{@"key":@"val"}] forKey:@"skuIds"];
    
	Product *product = [[Product alloc] initWithDictionary:productDictionary];
	
	STAssertEquals(product.createdAt, date, @"date should be date");
	STAssertEquals([product.amount intValue], 13, @"amount should be 13");
    STAssertEquals(product.skuIds[0], @"sku102", @"skuId[0] should be skuId102");
    STAssertEquals([product.skuIds[1] intValue], 99, @"skuId[1] should be 99");
	STAssertEquals([(NSDictionary*)product.skuIds[2] valueForKey:@"key"], @"val", @"skuId[2]['key'] should be val");
    
	[product release];
}

- (void)testDictionaryWithNestedObjectIntoObject {
	NSMutableDictionary *productDictionary = [NSMutableDictionary dictionary];
	[productDictionary setObject:@"foo" forKey:@"name"];
	
	NSMutableDictionary *productCategoryDictionary = [NSMutableDictionary dictionary];
	[productCategoryDictionary setObject:@"bar category" forKey:@"name"];
	
	[productDictionary setObject:productCategoryDictionary forKey:@"category"];
	
	Product *product = [[Product alloc] initWithDictionary:productDictionary];
	
	STAssertEquals(product.name, @"foo", @"name should be foo");
	
	STAssertNotNil(product.category, @"category should not be nil");
	
	STAssertNotNil(product.category, @"bar category");
	
	NSLog(@"product.category = %@", product.category);
	
	[product release];
}

- (NSMutableArray *)categoryCollectionArrayOfLevel:(NSString *)level {
	NSMutableArray *childCategoryArray = [NSMutableArray array];
	
	NSMutableDictionary *childCategory1_1 = [NSMutableDictionary dictionary];
	[childCategory1_1 setObject:[NSString stringWithFormat:@"%@.1", level] forKey:@"name"];	
	[childCategoryArray addObject:childCategory1_1];
	
	NSMutableDictionary *childCategory1_2 = [NSMutableDictionary dictionary];
	[childCategory1_2 setObject:[NSString stringWithFormat:@"%@.2", level] forKey:@"name"];
	[childCategoryArray addObject:childCategory1_2];
	
	return childCategoryArray;
}

- (void)testDictionaryWithArrayIntoObject {
	NSMutableDictionary *categoryDictionary = [NSMutableDictionary dictionary];
	[categoryDictionary setObject:@"1" forKey:@"name"];
	[categoryDictionary setObject:[self categoryCollectionArrayOfLevel:@"1"] forKey:@"children"];
	
	ProductCategory *category = [[ProductCategory alloc] initWithDictionary:categoryDictionary];
	
	STAssertTrue([category.name isEqualToString:@"1"], @"name should be 1");
	
	STAssertNotNil(category.children, @"category children should not be nil");
	STAssertTrue([category.children count] == 2, @"children count should == 2");
	
	id child1_1 = [category.children objectAtIndex:0];
	STAssertEqualObjects([child1_1 class], [ProductCategory class], @"category.children[0] should be ProductCategory");
	STAssertTrue([[child1_1 name] isEqualToString:@"1.1"], @"category.children[0].name should == '1.1'");
	
	id child1_2 = [category.children objectAtIndex:1];
	STAssertEqualObjects([child1_2 class], [ProductCategory class], @"category.children[1] should be ProductCategory");
	STAssertTrue([[child1_2 name] isEqualToString:@"1.2"], @"category.children[1].name should == '1.2'");

	[category release];
}

- (void)testDictionaryWithTreeArrayIntoObject {
	NSMutableDictionary *categoryDictionary = [NSMutableDictionary dictionary];
	[categoryDictionary setObject:@"1" forKey:@"name"];
	[categoryDictionary setObject:[self categoryCollectionArrayOfLevel:@"1"] forKey:@"children"];

	NSMutableDictionary *childCategory1_2 = [[categoryDictionary objectForKey:@"children"] objectAtIndex:1];
	[childCategory1_2 setObject:[self categoryCollectionArrayOfLevel:@"1.2"] forKey:@"children"];
	
	ProductCategory *category = [[ProductCategory alloc] initWithDictionary:categoryDictionary];
	
	id child1_2_1 = [[[category.children objectAtIndex:1] children] objectAtIndex:0];
	STAssertEqualObjects([child1_2_1 class], [ProductCategory class], @"category.children[0].children[1].name should be ProductCategory");
	STAssertTrue([[child1_2_1 name] isEqualToString:@"1.2.1"], @"category.children[1].children[0].name should == '1.2.1'");
	
	id child1_2_2 = [[[category.children objectAtIndex:1] children] objectAtIndex:1];
	
	NSLog(@"%@", child1_2_2);
	STAssertEqualObjects([child1_2_2 class], [ProductCategory class], @"category.children[0].children[1].name should be ProductCategory");
	STAssertTrue([[child1_2_2 name] isEqualToString:@"1.2.2"], @"category.children[1].children[1].name should == '1.2.2'");
}

- (void)testSerializingNestedTypesIntoJSON {
	NSMutableDictionary *categoryDictionary = [NSMutableDictionary dictionary];
	[categoryDictionary setObject:@"1" forKey:@"name"];
	[categoryDictionary setObject:[self categoryCollectionArrayOfLevel:@"1"] forKey:@"children"];
    
	NSMutableDictionary *childCategory1_2 = [[categoryDictionary objectForKey:@"children"] objectAtIndex:1];
	[childCategory1_2 setObject:[self categoryCollectionArrayOfLevel:@"1.2"] forKey:@"children"];
	
	ProductCategory *category = [[ProductCategory alloc] initWithDictionary:categoryDictionary];
	
    NSDictionary *toDictionary = [category toDictionary];
    
    //comparing the two dictionaries
	STAssertTrue([[toDictionary JSONString] isEqualToString:[categoryDictionary JSONString]], @"[toDictionary JSONString] should be [categoryDictionary JSONString]");
}
@end
