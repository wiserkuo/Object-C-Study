//
//  NewSymbolKeywordOut.m
//  Bullseye
//
//  Created by Yehsam on 2009/11/6.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import "NewSymbolKeywordOut.h"
#import "OutPacket.h"
@implementation NewSymbolKeywordOut

- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s searchGroup:(int)group
{

	if(self = [super init])
	{
		searchBySectorIDorIdent = group;		//Search by sector
		countIDtoSearch = sc;
		if(c)
		{
			sectorIDorIdent = malloc(sc * sizeof(UInt16));
			for(int i=0 ; i<sc ;i++)
			{
				sectorIDorIdent[i] = sID[i];
			}
		}
		count = c;
		pageNo = p;
		fieldType = f;
		searchType = s;
	}
	return self;
}

- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s searchBySectorId:(BOOL)search
{
    if(self = [super init])
    {
        searchBySectorID = search;		//Search by sector
        countIDtoSearch = sc;
        if(c)
        {
            sectorIDorIdent = malloc(sc * sizeof(UInt16));
            for(int i=0 ; i<sc ;i++)
            {
                sectorIDorIdent[i] = sID[i];
            }
        }
        count = c;
        pageNo = p;
        fieldType = f;
        searchType = s;
    }
    return self;
}


- (id)initWithSectorCount:(UInt8)sc SectorID:(UInt16*)sID countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s
{
	if(self = [super init])
	{
		searchBySectorIDorIdent = 1;		//Search by sector
		countIDtoSearch = sc;
		if(c)
		{
			sectorIDorIdent = malloc(sc * sizeof(UInt16));
			for(int i=0 ; i<sc ;i++)
			{
				sectorIDorIdent[i] = sID[i];
			}
		}
		count = c;
		pageNo = p;
		fieldType = f;
		searchType = s;
	}
	return self;
}


- (id)initWithIdentCount:(UInt8)sc IdentCode:(UInt16*)ic countPage:(UInt8)c Page_No:(UInt8)p FieldType:(UInt8)f SearchType:(UInt8)s
{
	if(self = [super init])
	{
		searchBySectorIDorIdent = sc;		//Search by Ident
		countIDtoSearch = sc;
		count = c;
		pageNo = p;
		fieldType = f;
		searchType = s;
	}
	return self;
}


- (void)setSecurityCount:(UInt8)c SecurityType:(UInt8*)st
{
	securityCount = c;
	if(c)
		securityType = malloc(c * sizeof(UInt8));
	for(int i=0 ; i<c ; i++)
	{
		securityType[i] = st[i];
	}
}

- (void)setKeyword:(NSString*)s
{
	if(s)
		keyword = [[NSString alloc] initWithString:s];
	else
		keyword = nil;
	length = [keyword lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (int)getPacketSize
{
	int size = 2+countIDtoSearch*sizeof(UInt16)+1+securityCount*sizeof(UInt8)+4+length;
	return size;
}

- (BOOL)encode : (NSObject*)account1 buffer:(char*)buffer length:(int)len
{
	char *tmpPtr = buffer;
	int tmp=0;
	OutPacketHeaderRef phead = (OutPacketHeaderRef)buffer;
	phead->escape = 0x1B;
	phead->message = 1;
	phead->command = 15;
	[CodingUtil setUInt16:(char*)&(phead->size) Value:len];
	buffer+=sizeof(OutPacketHeader);
    if (searchBySectorID) {
        *buffer++ = 1;
        *buffer++ = countIDtoSearch;
        
        for(int i=0 ; i<countIDtoSearch ; i++){
            [CodingUtil setUInt16:&buffer value:sectorIDorIdent[i]  needOffset:YES];
        }
    }else{
        *buffer++ = 2;//search by country code
        *buffer++ = countIDtoSearch;
        
        if(searchBySectorIDorIdent == 0)		//search by sectorID
        {
            
            *buffer++ = 'T';
            *buffer++ = 'W';
            
        }
        else if(searchBySectorIDorIdent == 1)
        {
            
            *buffer++ = 'U';
            *buffer++ = 'S';
        }
        else{
            *buffer++ = 'S';
            *buffer++ = 'S';
            *buffer++ = 'S';
            *buffer++ = 'Z';
        }
        
        
    }
    *buffer++ = securityCount;
    for(int i=0 ; i<securityCount ; i++)
        *buffer++ = securityType[i];
    *buffer++ = count;
    *buffer++ = pageNo;

    tmp = (tmp + 2)<<4;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        if ([keyword length] == 1) {
            
//            match
            *buffer++ = (tmp + 2);
        }else{
            
//            begins with(prefix)
            *buffer++ = (tmp + 0);
        }
    }else{
        *buffer++ = (tmp + 0);
    }
    

    *buffer++ = length;
    memcpy(buffer , [keyword UTF8String] , length);
	
	
	buffer = tmpPtr;
	return YES;
}

- (void)dealloc
{
	if(sectorIDorIdent) free(sectorIDorIdent);
	if(securityType) free(securityType);
}

@end
