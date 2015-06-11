//
//  NSDate+Extensions.h
//  Bullseye
//
//  Created by Connor on 13/8/30.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

/* ISO 8601 Data elements and interchange formats
 Input: 2015-02-16 06:13:06 +0000   (NSDate)
 Output: 2015-02-16T06:13:06Z       (NSString)
 */
+ (NSString *)UTCStringFromDate:(NSDate *)date;

/* ISO 8601 Data elements and interchange formats
 Input: 2015-02-16T06:13:06Z        (NSString)
 Output: 2015-02-16 06:13:06 +0000  (NSDate)
 */
+ (NSDate *)dateFromUTCString:(NSString *)dateString;

- (UInt16)uint16Value;
- (NSDate *)dayOffset:(NSInteger)dayOffset;
- (NSDate *)monthOffset:(NSInteger)monthOffset;
- (NSDate *)yearOffset:(NSInteger)yearOffset;

/* determine the date string format
 US: MM/DD/YYYY
 Others: YYYY/MM/DD
 */
+ (NSString *)dateStringFormat:(NSString *)dateString;
@end
