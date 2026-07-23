/*
 * © 2023-2024 GeoComply Solutions Inc.
 * All Rights Reserved.
 * NOTICE: All information contained herein is, and remains
 * the property of GeoComply Solutions Inc.
 * Dissemination, distribution, copying of this information or reproduction
 * of this material is strictly forbidden unless prior written permission
 * is obtained from GeoComply Solutions Inc.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GeoComplyBeaconScannerErrorDomain     @"GeoComplyBeaconScanner"

typedef enum : NSUInteger {
    GCBeaconScannerErrorCodeStopByTheApp = 900,
    GCBeaconScannerErrorCodeInvalidLicense = 901,
    GCBeaconScannerErrorCodeFeatureDisabled = 902,
    GCBeaconScannerErrorCodeInternalServiceError = 903,
    GCBeaconScannerErrorCodeAppEnterBackground = 904,
    GCBeaconScannerErrorCodeGeolocationInProgress = 914,
    GCBeaconScannerErrorCodeLocationPermissionIsNotGranted = 915,
    GCBeaconScannerErrorCodeBluetoothPermissionIsNotGranted = 916,
    GCBeaconScannerErrorCodeBluetoothIsDisabled = 917,
    GCBeaconScannerErrorCodeBluetoothIsNotSupported = 918,
    GCBeaconScannerErrorCodeLocationServiceIsDisabled = 919,
    GCBeaconScannerErrorCodeUnknownError = 920,
    GCBeaconScannerErrorCodePreciseLocationIsOff = 937,
} GCBeaconScannerErrorCode;

@protocol GCBeaconScannerDelegate <NSObject>
/**
 Tells the delegate the beacon updating has been just started
 */
- (void)didStartBeaconUpdating;
/**
 Tells the delegate the beacon updating founds the list of nearby beacon.
 
 @param beacons A array object of CLBeacon objects.
 */
- (void)didFindBeacons:(NSArray<CLBeacon*> * _Nonnull)beacons;
/**
 Tells the delegate the beacon updating founds no nearby beacon.
 */
- (void)didNotFindBeacon;
/**
 Tells the delegate the beacon updating is stopped.
 
 @param error A NSError object.
 */
- (void)didStopBeaconUpdatingWithError:(NSError * _Nonnull)error;

@end

@protocol GeoComplyBeaconScannerProtocol <NSObject>
@required
/**
Start scanning the nearby beacon.

@param delegate  this object will handle events, data emitted by the SDK while scanning nearby beacons
*/
- (void)startBeaconUpdatingWithDelegate:(id<GCBeaconScannerDelegate> _Nullable)delegate;

/**
Stop scanning the nearby beacon.
*/
- (void)stopBeaconUpdating;

/**
 Check whether the SDK is scanning nearby beacon.
*/
- (BOOL)isBeaconUpdating;

@end
