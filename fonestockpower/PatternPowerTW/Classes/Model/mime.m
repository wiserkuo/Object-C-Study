#import "mime.h"
#include <stdio.h>
#include <string.h>



static BOOL GetToken(PSTR *token, PSTR text, const char *tag, const char mark)
{
    UInt16 tagLen;
	
    if (*token != NULL) return FALSE;
	
    tagLen = strlen(tag);
	const char CharWhiteSpaces[] = " \t\r\n";	
    if (strncasecmp(text, tag, tagLen) == 0)
    {
        text += tagLen;
        text += strspn(text, CharWhiteSpaces);
		
        if (*text == mark)
        {
            text++;
            text += strspn(text, CharWhiteSpaces);
            *token = text;
            return TRUE;
        }
    }
	
    return FALSE;
}

BOOL CheckToken(PSTR text, const char *tag)
{
    return text != NULL &&
	strncasecmp(text, tag, strlen(tag)) == 0;
}

const char* UnpackMimeText(PSTR text, UInt16 *len)
{
    PSTR line, contentType, charSet, encoding;

    contentType = NULL;
    charSet = NULL;
    encoding = NULL;
	const char CharWhiteSpaces[] = " \t\r\n";
	const char CharLineFeed[]    = "\n";
	
	const char HeadContentType[] = "Content-Type";
	const char HeadCharSet[]     = "CharSet";
	const char HeadEncoding[]    = "Content-Transfer-Encoding";
	
	const char TokTextPlain[] = "text/plain";
	const char TokUTF8[]      = "\"utf-8\"";
	const char TokPrintable[] = "quoted-printable";
    line = strtok((char*)text, CharLineFeed);

    while (line != NULL && line < text + *len)
    {
        line += strspn(line, CharWhiteSpaces);

        if (GetToken(&contentType, line, HeadContentType, ':'))
            ;
        else if (GetToken(&charSet, line, HeadCharSet, '='))
            ;
        else if (GetToken(&encoding, line, HeadEncoding, ':'))
            ;
        else if (CheckToken(contentType, TokTextPlain) &&
                 CheckToken(charSet, TokUTF8) &&
                 CheckToken(encoding, TokPrintable) &&
                 *line == 0)
        {
            line++;
            *len = *len - (line - text);
            return line;
        }

        line = strtok(NULL, CharLineFeed);
    }

    *len = 0;
    return NULL;
}

/********************************************************************
//The end of CatalogMain and other related function implement
//Created by Yen
********************************************************************/
