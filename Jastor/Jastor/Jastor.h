//
//  Jastor.h
//  Jastor
//
//  Created by Elad Ossadon on 12/14/11.
//  http://devign.me | http://elad.ossadon.com | http://twitter.com/elado
//

@interface Jastor : NSObject <NSCoding>

@property (nonatomic, retain) NSString *objectId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSMutableDictionary *)toDictionary;

@end
