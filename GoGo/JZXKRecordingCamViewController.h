//
//  JZXKRecordingCamViewController.h
//  GoGo
//
//  Created by LazE on 6/5/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    PlayerStateCanStartRecording,
    PlayerStateCanStopRecording,
    PlayerStateCanStartPlayback,
    PlayerStateCanStopPlayback
} PlayerState;

@interface JZXKRecordingCamViewController : UIViewController
{
    BOOL startVideoWithRecord;
    BOOL finishRecordWithVideo;
    
    int recordingLength;
    int playbackLength;
}

@property (nonatomic) PlayerState state;

@property (weak, nonatomic) IBOutlet UILabel *autosLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *recordAutosControl;

@property (weak, nonatomic) IBOutlet UIImageView *videoNetworkImage;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;

@property (weak, nonatomic) IBOutlet UIView *topVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *topVideoPlayButton;

@property (weak, nonatomic) IBOutlet UIView *bottomVideoView;

@property (weak, nonatomic) IBOutlet UIImageView *bottomVideoRecordButton;

@property (weak, nonatomic) IBOutlet UILabel *bottomVideoTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomVideoCancelButton;

@property (nonatomic) NSDate *recordStartTime;
@property (nonatomic) NSTimeInterval videoPlaybackElapsedTime;

@property (nonatomic) NSString *requestID;
@property (nonatomic) NSString *requestTitle;
@property (nonatomic) NSString *requestType;
@property (nonatomic) NSString *requestSrcURL;

@property (nonatomic) NSString *requestRecordingURL;

@property (nonatomic) AVPlayer *topVideoPlayer;
@property (nonatomic) AVPlayer *bottomVideoPlayer;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureMovieFileOutput *captureVideoOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic) AVPlayerLayer *playbackLayer;

@property (nonatomic) NSTimer *playbackTimeLabelTimer;
@property (nonatomic) NSTimer *recordingTimeLabelTimer;

-(IBAction) autoRecordingSettingsChanged: (id) sender;
- (void)setupTopPlaybackPlayer;
@end
