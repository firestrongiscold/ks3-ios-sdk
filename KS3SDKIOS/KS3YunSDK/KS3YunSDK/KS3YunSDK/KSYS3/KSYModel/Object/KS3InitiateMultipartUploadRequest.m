//
//  KSS3InitiateMultipartUploadRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3InitiateMultipartUploadRequest.h"
#import "KS3Constants.h"
#import "KS3AccessControlList.h"
#import "KS3GrantAccessControlList.h"

@interface KS3InitiateMultipartUploadRequest ()

//@property (nonatomic, assign) BOOL expiresSet;
@end


@implementation KS3InitiateMultipartUploadRequest

-(id)init
{
    if (self = [super init])
    {
//        _expires = 0;
//        _expiresSet = NO;
    }
    
    return self;
}

- (id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket acl:(KS3AccessControlList *)acl grantAcl:(NSArray *)arrGrantAcl
{
    if(self = [self init])
    {
        self.key    = aKey;
        self.bucket = aBucket;
        self.httpMethod = kHttpMethodPost;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.acl = acl;
        self.arrGrantAcl = arrGrantAcl;
        self.kSYResource = [NSString stringWithFormat:@"/%@", aBucket];
        self.host = @"";
        
        //
        self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploads",self.kSYResource,_key];
        if (_acl != nil) {
            
            self.kSYHeader = [@"x-kss-acl:" stringByAppendingString:_acl.accessACL];
            self.kSYHeader = [NSString stringWithFormat:@"%@\n",self.kSYHeader];
        }
        if (_arrGrantAcl != nil) {
            [self sortGrantAcl]; // **** ACL的 x-kss 需要先排序
            for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
                KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
                NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", grantAcl.identifier];
                strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", grantAcl.displayName];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:[grantAcl.accessGrantACL stringByAppendingString:@":"]];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:strValue];
                self.kSYHeader = [self.kSYHeader stringByAppendingString:@"\n"];
            }
        }
    }
    
    return self;
}


- (void)sortGrantAcl {
    NSMutableArray *arrAccessGrantAcl = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
        KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
        [arrAccessGrantAcl addObject:grantAcl.accessGrantACL];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *resultArray = [arrAccessGrantAcl sortedArrayUsingDescriptors:descriptors];
    NSMutableArray *arrGrantAcl = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
        NSString *strAccessGrantAcl = resultArray[i];
        for (NSInteger j = 0; j < _arrGrantAcl.count; j ++) {
            KS3GrantAccessControlList *grantAcl = _arrGrantAcl[j];
            if ([grantAcl.accessGrantACL isEqualToString:strAccessGrantAcl] == YES) {
                [arrGrantAcl addObject:grantAcl];
                break;
            }
        }
    }
    self.arrGrantAcl = arrGrantAcl;
}

//-(void)setExpires:(int32_t)exp
//{
//    _expires    = exp;
//    _expiresSet = YES;
//}

-(NSMutableURLRequest *)configureURLRequest
{
//    self.kSYResource = [NSString stringWithFormat:@"%@/%@?uploads",self.kSYResource,_key];
    self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com/%@?uploads", self.bucket, self.key];
//    self.host = [NSString stringWithFormat:@"http://115.231.96.27:8080/%@/%@?uploads", self.bucket, self.key];
    
    if (_acl != nil) {
        [self.urlRequest setValue:_acl.accessACL forHTTPHeaderField:@"x-kss-acl"];
    }
    
    if (_arrGrantAcl != nil) {
        for (NSInteger i = 0; i < _arrGrantAcl.count; i ++) {
            KS3GrantAccessControlList *grantAcl = _arrGrantAcl[i];
            NSString *strValue = [NSString stringWithFormat:@"id=\"%@\", ", grantAcl.identifier];
            strValue = [strValue stringByAppendingFormat:@"displayName=\"%@\"", grantAcl.displayName];
            [self.urlRequest setValue:strValue forHTTPHeaderField:grantAcl.accessGrantACL];
        }
    }
    
    [super configureURLRequest];
    
    [self.urlRequest setHTTPMethod:kHttpMethodPost];
    
    if (nil != self.contentEncoding) {
        [self.urlRequest setValue:self.contentEncoding
               forHTTPHeaderField:kKSHttpHdrContentEncoding];
    }
    if (nil != self.contentDisposition) {
        [self.urlRequest setValue:self.contentDisposition
               forHTTPHeaderField:kKSHttpHdrContentDisposition];
    }
    if (nil != self.cacheControl) {
        [self.urlRequest setValue:self.cacheControl
               forHTTPHeaderField:kKSHttpHdrCacheControl];
    }
    if (nil != _expires) {
        [self.urlRequest setValue:_expires forHTTPHeaderField:@"Expires"];
    }
    if (nil != _xkssMeta) {
        [self.urlRequest setValue:_xkssMeta forHTTPHeaderField:@"x-kss-meta-"];
    }
    if (nil != _xkssStorageClass) {
        [self.urlRequest setValue:_xkssStorageClass forHTTPHeaderField:@"x-kss-storage-class"];
    }
    if (nil != _xkssWebSiteRedirectLocation) {
        [self.urlRequest setValue:_xkssWebSiteRedirectLocation forHTTPHeaderField:@"x-kss-website-redirect-location"];
    }
    
    // **** acl header
    if (nil != _xkssAcl) {
        [self.urlRequest setValue:_xkssAcl forHTTPHeaderField:@"x-kss-acl"];
    }
    return self.urlRequest;
}


@end