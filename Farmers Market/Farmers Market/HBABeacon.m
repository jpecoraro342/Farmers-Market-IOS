//
//  GCPBeacon.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/28/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBABeacon.h"

@implementation HBABeacon

-(instancetype)init {
    self = [super init];
    if (self) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        [self.timeFormatter setDateFormat:@"HH:mm:ss:SSS"];
    }
    return self;
}

-(void)updateBeaconWithCLBeacon:(CLBeacon *)beacon {
    self.rssi = beacon.rssi;
    self.accuracy = beacon.accuracy;
    self.distance = [self nameForProximity:beacon.proximity];
}

-(void)updateIdentifier {
    self.identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [self.uuid UUIDString], self.major, self.minor];
}

-(void)updateProximityReset {
    if ([self.distance isEqualToString:@"Unknown"]) {
        self.hasBeenReset = YES;
    }
    else if ([self.distance isEqualToString:@"Far"]) {
        self.hasBeenReset = YES;
    }
}

-(NSString *)nameForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            self.hasBeenReset = YES;
            return @"Unknown";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityFar:
            self.hasBeenReset = YES;
            return @"Far";
            break;
    }
}

-(BOOL)isEqualToCLBeacon:(CLBeacon *)beacon {
    if ([[beacon.proximityUUID UUIDString] isEqualToString:[self.uuid UUIDString]] && [beacon.major isEqual: @(self.major)] && [beacon.minor isEqual: @(self.minor)]) {
        return YES;
    } else {
        return NO;
    }
}

-(NSUInteger)hash {
    return [self.identifier hash];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[HBABeacon class]]) {
        return NO;
    }
    else {
        return [self.identifier isEqualToString:[object identifier]];
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Name: %@\nUUID:%@\nSignal: %zd\nMajor: %zd\nMinor: %zd\nDistance: %@\nAccuracy: +/- %.2fm", self.name, [self.uuid UUIDString], self.rssi, self.major, self.minor, self.distance, self.accuracy];
}

@end
