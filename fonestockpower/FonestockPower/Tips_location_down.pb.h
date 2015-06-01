// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class tips_location_down;
@class tips_location_downBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef NS_ENUM(SInt32, tips_location_downdata_type) {
  tips_location_downdata_typeDivergenceUs = 0,
  tips_location_downdata_typeDivergenceTw = 1,
  tips_location_downdata_typeDivergenceCn = 2,
  tips_location_downdata_typeDivergenceHk = 3,
  tips_location_downdata_typePatternUs = 4,
  tips_location_downdata_typePatternTw = 5,
  tips_location_downdata_typePatternCn = 6,
  tips_location_downdata_typePatternHk = 7,
};

BOOL tips_location_downdata_typeIsValidValue(tips_location_downdata_type value);


@interface TipsLocationDownRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface tips_location_down : PBGeneratedMessage {
@private
  BOOL hasLocation_:1;
  BOOL hasKey_:1;
  BOOL hasType_:1;
  NSString* location;
  NSData* key;
  tips_location_downdata_type type;
}
- (BOOL) hasType;
- (BOOL) hasLocation;
- (BOOL) hasKey;
@property (readonly) tips_location_downdata_type type;
@property (readonly, strong) NSString* location;
@property (readonly, strong) NSData* key;

+ (tips_location_down*) defaultInstance;
- (tips_location_down*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (tips_location_downBuilder*) builder;
+ (tips_location_downBuilder*) builder;
+ (tips_location_downBuilder*) builderWithPrototype:(tips_location_down*) prototype;
- (tips_location_downBuilder*) toBuilder;

+ (tips_location_down*) parseFromData:(NSData*) data;
+ (tips_location_down*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (tips_location_down*) parseFromInputStream:(NSInputStream*) input;
+ (tips_location_down*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (tips_location_down*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (tips_location_down*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface tips_location_downBuilder : PBGeneratedMessageBuilder {
@private
  tips_location_down* result;
}

- (tips_location_down*) defaultInstance;

- (tips_location_downBuilder*) clear;
- (tips_location_downBuilder*) clone;

- (tips_location_down*) build;
- (tips_location_down*) buildPartial;

- (tips_location_downBuilder*) mergeFrom:(tips_location_down*) other;
- (tips_location_downBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (tips_location_downBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasType;
- (tips_location_downdata_type) type;
- (tips_location_downBuilder*) setType:(tips_location_downdata_type) value;
- (tips_location_downBuilder*) clearType;

- (BOOL) hasLocation;
- (NSString*) location;
- (tips_location_downBuilder*) setLocation:(NSString*) value;
- (tips_location_downBuilder*) clearLocation;

- (BOOL) hasKey;
- (NSData*) key;
- (tips_location_downBuilder*) setKey:(NSData*) value;
- (tips_location_downBuilder*) clearKey;
@end


// @@protoc_insertion_point(global_scope)
