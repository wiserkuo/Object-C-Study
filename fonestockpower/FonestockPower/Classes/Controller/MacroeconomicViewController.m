//
//  MacroeconomicViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MacroeconomicViewController.h"
#import "MacroeconomicTableViewCell.h"
#import "MacroeconomicDrawViewController.h"
#import "UIViewController+CustomNavigationBar.h"
@interface MacroeconomicViewController ()
{
    int indexNum;
    int beginID;
    NSString *tagName;
    NSString *tagID;
    NSMutableDictionary *mainDict;
    NSMutableArray *titleArray;
    NSMutableArray *nameArray;
    NSMutableArray *contentArray;
    NSMutableArray *selectNameArray;
    NSMutableArray *selectTypeArray;
    NSMutableArray *selectDateArray;
    NSMutableArray *selectRatioArray;
    NSMutableArray *selectValueArray;
    NSMutableArray *typeArray;
    NSMutableArray *contentTypeArray;
    
    NSMutableArray *indexIDArray;
    NSMutableArray *selectIDArray;
    
    NSMutableArray *dateArray;
    NSMutableArray *ratioArray;
    NSMutableArray *valueArray;
    
    BOOL countryFlag;
    BOOL firstFlag;
    BOOL titleFlag;
    BOOL typeFlag;
    BOOL indexFlag;
    BOOL initFlag;
    UIScrollView *topScrollView;
    UIView *topView;
    FSUIButton *topBtn;
    FSUIButton *sameBtn;
    FSUIButton *behindBtn;
    FSUIButton *otherBtn;
    NSString *contentText;
    NSString *contentText2;
    NSString *country;
    UITableView *mainTableView;
    
    NSXMLParser *parserTitle;
    NSXMLParser *parserID;
    
    NSMutableDictionary *timeDict;
    
    NSString *titleTime;
    NSString *idTime;
    
    NSString *timePath;
    
    NSData *titleData;
    NSData *idData;
    BOOL titleSave;
    BOOL idSave;
}
@end

@implementation MacroeconomicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"總經", @"Launcher", nil);
    [self setUpImageBackButton];
    [self initArray];
	[self initXML];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initArray
{
    mainDict = [[NSMutableDictionary alloc] init];
    titleArray = [[NSMutableArray alloc] init];
    nameArray = [[NSMutableArray alloc] init];
    typeArray = [[NSMutableArray alloc] init];
    contentArray = [[NSMutableArray alloc] init];
    contentTypeArray = [[NSMutableArray alloc] init];
    indexIDArray = [[NSMutableArray alloc] init];
    
    dateArray = [[NSMutableArray alloc] init];
    ratioArray = [[NSMutableArray alloc] init];
    valueArray = [[NSMutableArray alloc] init];
    selectDateArray = [[NSMutableArray alloc] init];
    selectRatioArray = [[NSMutableArray alloc] init];
    selectValueArray = [[NSMutableArray alloc] init];
    selectIDArray = [[NSMutableArray alloc] init];
}

-(void)initXML
{
    if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
        beginID = 4;
    }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"us"]){
        beginID = 9;
    }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"cn"]){
        beginID = 13;
    }
    
    
    timePath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      @"Macroeconomic.plist"];
    timeDict = [NSMutableDictionary dictionaryWithContentsOfFile:timePath];
    if(timeDict){
        titleSave = YES;
        titleTime = [timeDict objectForKey:@"TitleTime"];
        NSURL *urlTitle = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=meta&time_stamp=%@",[FSFonestock sharedInstance].queryServerURL, titleTime]];
        titleData = [[NSData alloc] initWithContentsOfURL:urlTitle];
        parserTitle = [[NSXMLParser alloc] initWithData:titleData];
        [parserTitle setDelegate:self];
        [parserTitle parse];
        
        idSave = YES;
        idTime = [timeDict objectForKey:[NSString stringWithFormat:@"ID%dTime", beginID]];
        NSURL *urlID = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=snapshot_by_class&class_id=%d&time_stamp=%@",[FSFonestock sharedInstance].queryServerURL, beginID, idTime]];
        idData = [[NSData alloc] initWithContentsOfURL:urlID];
        parserID = [[NSXMLParser alloc] initWithData:idData];
        [parserID setDelegate:self];
        [parserID parse];
        
    }else{
        timeDict = [[NSMutableDictionary alloc] init];
        NSURL *urlTitle = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=meta&time_stamp=NULL",[FSFonestock sharedInstance].queryServerURL]];
        titleData = [[NSData alloc] initWithContentsOfURL:urlTitle];
        
        NSString *titlePath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                               @"MacroeconomicTitle.xml"];
        [titleData writeToFile:titlePath atomically:YES];
        parserTitle = [[NSXMLParser alloc] initWithData:titleData];
        [parserTitle setDelegate:self];
        [parserTitle parse];
        
        
        NSURL *urlID = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=snapshot_by_class&class_id=%d&time_stamp=NULL",[FSFonestock sharedInstance].queryServerURL, beginID]];
        idData = [[NSData alloc] initWithContentsOfURL:urlID];
        NSString *idPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                                                @"MacroeconomicID%d.xml", beginID]];
        [idData writeToFile:idPath atomically:YES];
        parserID = [[NSXMLParser alloc] initWithData:idData];
        [parserID setDelegate:self];
        [parserID parse];
    }
}

-(void)sendFileXML
{
    NSString *titlePath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                           @"MacroeconomicTitle.xml"];
    titleData = [[NSData alloc] initWithContentsOfFile:titlePath];
    parserTitle = [[NSXMLParser alloc] initWithData:titleData];
    [parserTitle setDelegate:self];
    [parserTitle parse];
}

-(void)sendIDFileXML
{
    NSString *idPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                                            @"MacroeconomicID%d.xml", beginID]];
    idData = [[NSData alloc] initWithContentsOfFile:idPath];
    parserID = [[NSXMLParser alloc] initWithData:idData];
    [parserID setDelegate:self];
    [parserID parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([parser isEqual:parserTitle]){
        tagName = elementName;
        if([elementName isEqualToString:@"index"]){
            titleFlag = YES;
            if(countryFlag){
            [indexIDArray addObject:[attributeDict objectForKey:@"id"]];
            }
        }
    
    }else{
        tagID = elementName;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([parser isEqual:parserTitle]){
        if(![string isEqualToString:@"\n"]){
            if(countryFlag){
                contentText = [contentText stringByAppendingString:string];
            }
            if([tagName isEqualToString:@"name"]){
                country = string;
            }
            if([tagName isEqualToString:@"data_type"]){
                typeFlag = YES;
            }
            if([tagName isEqualToString:@"time_stamp"]){
                titleTime = string;
            }
            if([tagName isEqualToString:@"code"]){
                if([string isEqualToString:@"1"]){
                    [self sendFileXML];
                }else if(titleSave){
                    NSString *titlePath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                                           @"MacroeconomicTitle.xml"];
                    [titleData writeToFile:titlePath atomically:YES];
                    titleSave = NO;
                }
            }
        }
    }else{
        if(![string isEqualToString:@"\n"]){
            if([tagID isEqualToString:@"date"]){
                if([[[FSFonestock sharedInstance].appId substringToIndex:2]isEqualToString:@"us"]){
                    NSString *month = [string substringWithRange:NSMakeRange(5, 2)];
                    NSString *year = [string substringToIndex:4];
                    [dateArray addObject:[NSString stringWithFormat:@"%@/%@",month, year]];
                }else{
                    [dateArray addObject:string];
                }
            }
            if([tagID isEqualToString:@"grow_ratio"]){
                [ratioArray addObject:string];
            }
            if([tagID isEqualToString:@"value"]){
                [valueArray addObject:string];
            }
            if([tagID isEqualToString:@"time_stamp"]){
                idTime = string;
            }
            if([tagID isEqualToString:@"code"]){
                if([string isEqualToString:@"1"]){
                    [self sendIDFileXML];
                }else if(idSave){
                    NSString *idPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                                                            @"MacroeconomicID%d.xml", beginID]];
                    [idData writeToFile:idPath atomically:YES];
                    idSave = NO;
                }
            }
        }
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([parser isEqual:parserTitle]){
        if([elementName isEqualToString:@"index"]){
            titleFlag = NO;
        }
        
        if(countryFlag){
            if([tagName isEqualToString:@"name"]){
                if(!titleFlag){
                    [titleArray addObject:contentText];
                }else{
                    [contentArray addObject:contentText];
                }
            }
            if(typeFlag){
                if([tagName isEqualToString:@"data_type"]){
                    [contentTypeArray addObject:contentText];
                    typeFlag = NO;
                }
            }
        }
        contentText = @"";
        
        
        if(countryFlag){
            if([elementName isEqualToString:@"level2"]){
                [nameArray addObject:[contentArray copy]];
                [typeArray addObject:[contentTypeArray copy]];
                [contentArray removeAllObjects];
                [contentTypeArray removeAllObjects];
                [selectIDArray addObject:[indexIDArray copy]];
                [indexIDArray removeAllObjects];
            }
        }
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            if([country isEqualToString:@"台灣"]){
                countryFlag = YES;
            }
        }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"us"]){
            if([country isEqualToString:@"美國"]){
                countryFlag = YES;
            }
        }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"cn"]){
            if([country isEqualToString:@"大陸"]){
                countryFlag = YES;
            }
        }
        
        if([elementName isEqualToString:@"level1"]){
            countryFlag = NO;
        }
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if([parser isEqual:parserTitle]){
        [mainDict setObject:[nameArray objectAtIndex:0] forKey:@"Name"];
        [mainDict setObject:[typeArray objectAtIndex:0] forKey:@"Type"];
        [timeDict setObject:titleTime forKey:@"TitleTime"];
    }
    if([parser isEqual:parserID]){
        [selectDateArray addObject:[dateArray copy]];
        [selectRatioArray addObject:[ratioArray copy]];
        [selectValueArray addObject:[valueArray copy]];
        [timeDict setObject:idTime forKey:[NSString stringWithFormat:@"ID%dTime", beginID]];
        beginID ++;
        [dateArray removeAllObjects];
        [ratioArray removeAllObjects];
        [valueArray removeAllObjects];
        int endID;
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            endID = 8;
        }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"us"]){
            endID = 12;
        }else{
            endID = 17;
        }
        if(beginID <= endID){
            if([timeDict objectForKey:[NSString stringWithFormat:@"ID%dTime", beginID]]){
                idTime = [timeDict objectForKey:[NSString stringWithFormat:@"ID%dTime", beginID]];
                NSURL *urlID = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=snapshot_by_class&class_id=%d&time_stamp=%@",[FSFonestock sharedInstance].queryServerURL, beginID, idTime]];
                NSData *dataID = [[NSData alloc] initWithContentsOfURL:urlID];
                parserID = [[NSXMLParser alloc] initWithData:dataID];
                [parserID setDelegate:self];
                [parserID parse];
                idSave = YES;
            }else{
                NSURL *urlID = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=snapshot_by_class&class_id=%d&time_stamp=NULL",[FSFonestock sharedInstance].queryServerURL, beginID]];
                NSData *dataID = [[NSData alloc] initWithContentsOfURL:urlID];
                NSString *idPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                                                        @"MacroeconomicID%d.xml", beginID]];
                [dataID writeToFile:idPath atomically:YES];
                parserID = [[NSXMLParser alloc] initWithData:dataID];
                [parserID setDelegate:self];
                [parserID parse];
            }
        }else{
            [timeDict writeToFile:timePath atomically:YES];
        }
        
        [mainDict setObject:[selectDateArray objectAtIndex:0] forKey:@"Date"];
        [mainDict setObject:[selectRatioArray objectAtIndex:0] forKey:@"Ratio"];
        [mainDict setObject:[selectValueArray objectAtIndex:0] forKey:@"Value"];
    }
    
    if(!initFlag){
        [self initView];
        [self initTableView];
        [self processLayout];
        initFlag = YES;
    }
    
}

-(void)initView
{
    topView = [[UIView alloc] initWithFrame:self.view.frame];
    
    topBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [topBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn setTitle:[titleArray objectAtIndex:0] forState:UIControlStateNormal];
    topBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:topBtn];
    
    sameBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [sameBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [sameBtn setTitle:[titleArray objectAtIndex:1] forState:UIControlStateNormal];
    sameBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:sameBtn];
    
    behindBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [behindBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [behindBtn setTitle:[titleArray objectAtIndex:2] forState:UIControlStateNormal];
    behindBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:behindBtn];
    
    otherBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [otherBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [otherBtn setTitle:[titleArray objectAtIndex:3] forState:UIControlStateNormal];
    otherBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:otherBtn];
    
    topScrollView = [[UIScrollView alloc] init];
    topScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    topScrollView.bounces = NO;
    [topScrollView addSubview:topView];
    [self.view addSubview:topScrollView];
}

-(void)initTableView
{
    selectNameArray = [nameArray objectAtIndex:0];
    selectTypeArray = [typeArray objectAtIndex:0];
    topBtn.selected = YES;
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(topBtn, sameBtn, behindBtn, otherBtn, topScrollView, mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topScrollView(44)][mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topScrollView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topBtn(180)]-5-[sameBtn(180)]-5-[behindBtn(180)]-5-[otherBtn(180)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topBtn(44)]" options:0 metrics:nil views:viewController]];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [topScrollView setContentSize:CGSizeMake(740, 44)];
    [topView setFrame:CGRectMake(0, 0, topScrollView.contentSize.width, topScrollView.contentSize.height)];
    [self.view layoutSubviews];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MacroeconomicCell";
    MacroeconomicTableViewCell *cell = (MacroeconomicTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MacroeconomicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.nameLabel.text = [[mainDict objectForKey:@"Name"] objectAtIndex:indexPath.row];
    cell.nameDetailLabel.text = [NSString stringWithFormat:@"(%@)", [[mainDict objectForKey:@"Type"] objectAtIndex:indexPath.row]];
    cell.dateLabel.text = [[mainDict objectForKey:@"Date"] objectAtIndex:indexPath.row];
    cell.valueLabel.text = [CodingUtil getMacroeconomicValue:[(NSNumber *)[[mainDict objectForKey:@"Value"]objectAtIndex:indexPath.row]doubleValue]];
    if([(NSNumber *)[[mainDict objectForKey:@"Ratio"] objectAtIndex:indexPath.row]doubleValue] < 0){
        cell.arrowImage.image = [UIImage imageNamed:@"downArrow"];
    }else{
        cell.arrowImage.image = [UIImage imageNamed:@"upArrow"];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[mainDict objectForKey:@"Name"] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

-(void)btnHandler:(UIButton *)sender
{
    topBtn.selected = NO;
    sameBtn.selected = NO;
    behindBtn.selected = NO;
    otherBtn.selected = NO;
    sender.selected = YES;
    if([sender isEqual:topBtn]){
        indexNum = 0;
    }else if([sender isEqual:sameBtn]){
        indexNum = 1;
    }else if([sender isEqual:behindBtn]){
        indexNum = 2;
    }else{
        
        indexNum = 3;
    }
    [mainDict setObject:[nameArray objectAtIndex:indexNum] forKey:@"Name"];
    [mainDict setObject:[typeArray objectAtIndex:indexNum] forKey:@"Type"];
    [mainDict setObject:[selectDateArray objectAtIndex:indexNum] forKey:@"Date"];
    [mainDict setObject:[selectRatioArray objectAtIndex:indexNum] forKey:@"Ratio"];
    [mainDict setObject:[selectValueArray objectAtIndex:indexNum] forKey:@"Value"];
    [mainTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[[MacroeconomicDrawViewController alloc]initWithIndexID:[[selectIDArray objectAtIndex:indexNum]objectAtIndex:indexPath.row] ID:selectIDArray Name:nameArray Index:indexNum IndexRow:(int)indexPath.row Title:titleArray] animated:NO];
}
@end
