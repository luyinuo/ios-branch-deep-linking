//
//  BranchLoadRewardsRequest.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 5/22/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BranchLoadRewardsRequest.h"
#import "BNCPreferenceHelper.h"
#import "BranchConstants.h"

@interface BranchLoadRewardsRequest ()

@property (strong, nonatomic) callbackWithStatus callback;

@end

@implementation BranchLoadRewardsRequest

- (id)initWithCallback:(callbackWithStatus)callback {
    if (self = [super init]) {
        _callback = callback;
    }

    return self;
}

- (void)makeRequest:(BNCServerInterface *)serverInterface key:(NSString *)key callback:(BNCServerCallback)callback {
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    NSString *endpoint = [BRANCH_REQUEST_ENDPOINT_LOAD_REWARDS stringByAppendingPathComponent:preferenceHelper.identityID];
    [serverInterface getRequest:nil url:[preferenceHelper getAPIURL:endpoint] key:key callback:callback];
}

- (void)processResponse:(BNCServerResponse *)response error:(NSError *)error {
    if (error) {
        if (self.callback) {
            self.callback(NO, error);
        }
        return;
    }

    BOOL hasUpdated = NO;
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    if ([[response.data allKeys] count]) {
        for (NSString *key in response.data) {
            NSInteger credits = [response.data[key] integerValue];
        
            if (credits != [preferenceHelper getCreditCountForBucket:key]) {
                hasUpdated = YES;
            }
        
            [preferenceHelper setCreditCount:credits forBucket:key];
        }
    }
    else {
        [preferenceHelper clearUserCreditsAndCounts];
        [preferenceHelper setCreditCount:0 forBucket:@"default"];
    }

    if (self.callback) {
        self.callback(hasUpdated, nil);
    }
}

@end
