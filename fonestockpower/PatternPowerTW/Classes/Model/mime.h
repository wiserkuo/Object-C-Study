//
//  mime.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef const char *PSTR;
//static BOOL GetToken(PSTR *token, PSTR text, const char *tag, const char mark);
BOOL CheckToken(PSTR text, const char *tag);
const char* UnpackMimeText(PSTR text, UInt16 *len);
