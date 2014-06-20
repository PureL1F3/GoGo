//
//  JZXKRecordingCamViewController.m
//  GoGo
//
//  Created by LazE on 6/5/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "JZXKRecordingCamViewController.h"

@interface JZXKRecordingCamViewController ()

@end

@implementation JZXKRecordingCamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Record"];

    //back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(navigateBack:)];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    //self.navigationItem.backBarButtonItem.title = @"";
    //upload button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload"
                                                                    style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    
    //top play button tap gesture recognizer
    UITapGestureRecognizer *topVideoPlayButtonTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTopVideoPlayButtonTap:)];
    [self.topVideoPlayButton addGestureRecognizer:topVideoPlayButtonTapRecognizer];


    //bottom record button tap gesture recognizer
    UITapGestureRecognizer *bottomRecordVideoButtonTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleBottomVideoRecordButtonTap:)];
    [self.bottomVideoRecordButton addGestureRecognizer:bottomRecordVideoButtonTapRecognizer];

    //bottom cancel button tap gesture recognizer
    UITapGestureRecognizer *bottomVideoCancelButtonTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleBottomVideoCancelButtonTap:)];
    [self.bottomVideoCancelButton addGestureRecognizer:bottomVideoCancelButtonTapRecognizer];
    
    
    //setup top video player
    [self setupRecordingVideoURL];
    [self setupTopPlaybackPlayer];
    [self setupTopPlayback];
    self.state = PlayerStateCanStartRecording;
    [self autoRecordingSettingsChanged:nil];
    [self loadState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)navigateBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setupTopPlaybackPlayer
{
    NSLog(@"Setting up top playback layer");
    NSURL *videoURL = [NSURL URLWithString:self.requestSrcURL];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    self.topVideoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    [self.topVideoPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)setupTopPlayback
{
    CALayer *videoLayer = self.topVideoView.layer;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.topVideoPlayer];
    playerLayer.frame = self.topVideoView.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [videoLayer addSublayer:playerLayer];
}

- (void)setupBottomPlayback
{
    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:self.requestRecordingURL];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    self.bottomVideoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    CALayer *videoLayer = self.bottomVideoView.layer;
    self.playbackLayer = [AVPlayerLayer playerLayerWithPlayer:self.bottomVideoPlayer];
    self.playbackLayer.frame = self.bottomVideoView.bounds;
    self.playbackLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [videoLayer addSublayer:self.playbackLayer];
}

- (void)clearBottomPlayback
{
    [self.playbackLayer removeFromSuperlayer];
}

- (void)setupBottomRecordingSession
{
    self.session = [[AVCaptureSession alloc] init];
    [self.session beginConfiguration];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    NSError *error;
    for(AVCaptureDevice *device in [AVCaptureDevice devices])
    {
        if([device hasMediaType:AVMediaTypeVideo] && ([device position] == AVCaptureDevicePositionFront))
        {
            AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if([self.session canAddInput:videoInput])
            {
                [self.session addInput:videoInput];
            }
        }
        if([device hasMediaType:AVMediaTypeAudio])
        {
            AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if([self.session canAddInput:audioInput])
            {
                [self.session addInput:audioInput];
            }
        }
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    if([self.session canAddOutput:videoDataOutput])
    {
        [self.session addOutput:videoDataOutput];
    }
    
    
    self.captureVideoOutput = [[AVCaptureMovieFileOutput alloc] init];
    if([self.session canAddOutput:self.captureVideoOutput])
    {
        [self.session addOutput:self.captureVideoOutput];
    }
    AVCaptureConnection *CaptureConnection = [self.captureVideoOutput connectionWithMediaType:AVMediaTypeVideo];
    CaptureConnection.videoMirrored = true;
    CaptureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.session commitConfiguration];
}

- (void)startBottomRecordingSession
{
    [self.session startRunning];
    CALayer *cameraLayer = self.bottomVideoView.layer;
    self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.capturePreviewLayer.frame = self.bottomVideoView.bounds;
    self.capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.capturePreviewLayer captureDevicePointOfInterestForPoint:CGPointMake(0, 160)];
    [cameraLayer addSublayer:self.capturePreviewLayer];
}

- (void)stopBottomRecordingSession
{
    [self.session stopRunning];
    [self.capturePreviewLayer removeFromSuperlayer];
    
    [self.session beginConfiguration];
    for( AVCaptureOutput *output in self.session.outputs)
    {
        [self.session removeOutput:output];
    }
    for( AVCaptureInput *input in self.session.inputs)
    {
        [self.session removeInput:input];
    }
    [self.session commitConfiguration];
    
    self.session = nil;
}


- (void)startTopPlayback
{
    if(self.state == PlayerStateCanStopRecording)
    {
        self.topVideoPlayButton.hidden = true;
        self.videoPlaybackElapsedTime = fabs([self.recordStartTime timeIntervalSinceNow]);
    }
    else if(self.state == PlayerStateCanStopPlayback)
    {
        self.topVideoPlayer.muted = true;
    }
    [self.topVideoPlayer play];
}

- (void)stopTopPlayback
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTopPlayback)object:nil];
    [self.topVideoPlayer pause];
    [self.topVideoPlayer seekToTime:kCMTimeZero];
}

- (void)startBottomPlayback
{
    [self.bottomVideoPlayer play];
}

- (void)stopBottomPlayback
{
    [self.bottomVideoPlayer pause];
    [self.bottomVideoPlayer seekToTime:kCMTimeZero];
}

- (void)startRecording
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.requestRecordingURL])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:self.requestRecordingURL error:&error] == NO)
        {
        }
    }
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:self.requestRecordingURL];
    [self.captureVideoOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];

    
    recordingLength = 0;
    [self updateRecordingTimeLabel:nil];
    
    self.recordingTimeLabelTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRecordingTimeLabel:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.recordingTimeLabelTimer forMode:NSRunLoopCommonModes];
}

- (void)stopRecording
{
    [self.recordingTimeLabelTimer invalidate];
    recordingLength--;
    [self stopTopPlayback];
    [self.captureVideoOutput stopRecording];
}

- (void)startPlayback
{
    [self startBottomPlayback];
    if(self.videoPlaybackElapsedTime == 0)
    {
        [self startTopPlayback];
    }
    else
    {
        [self performSelector:@selector(startTopPlayback) withObject:self afterDelay:self.videoPlaybackElapsedTime];
    }
    
    self.playbackTimeLabelTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackTimeLabel:) userInfo:nil repeats:YES];
    [self updatePlaybackTimeLabel:self.playbackTimeLabelTimer];
    [[NSRunLoop mainRunLoop] addTimer:self.playbackTimeLabelTimer forMode:NSRunLoopCommonModes];

}

- (void)stopPlayback
{
    [self.playbackTimeLabelTimer invalidate];
    [self stopTopPlayback];
    [self stopBottomPlayback];
}

- (void)handleTopVideoPlayButtonTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Tapped top video play button");
    
    if(self.state == PlayerStateCanStopRecording)
    {
        [self startTopPlayback];
    }
}

- (void)handleBottomVideoRecordButtonTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Tapped bottom record button");
    
    switch(self.state)
    {
        case PlayerStateCanStartRecording:
            self.state = PlayerStateCanStopRecording;
            break;
        case PlayerStateCanStopRecording:
            [self stopRecording];
            [self stopBottomRecordingSession];
            self.state = PlayerStateCanStartPlayback;
            break;
        case PlayerStateCanStartPlayback:
            self.state = PlayerStateCanStopPlayback;
            break;
        case PlayerStateCanStopPlayback:
            [self stopPlayback];
            self.state = PlayerStateCanStartPlayback;
            break;
    }
    
    [self loadState];
}

- (void)handleBottomVideoCancelButtonTap:(UITapGestureRecognizer *)recognizer
{
    if(self.state == PlayerStateCanStopPlayback)
    {
        [self stopPlayback];
    }
    [self clearBottomPlayback];
    self.topVideoPlayer.muted = false;
    self.state = PlayerStateCanStartRecording;
    [self loadState];
}

- (void)setupRecordingVideoURL
{
    NSString *videoFileName = [NSString stringWithFormat:@"%@.mp4", self.requestID];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoFileName];
    self.requestRecordingURL = filePath;

    NSLog(@"Setting recording URL to %@", self.requestRecordingURL);
}

- (void)loadState
{
    NSLog(@"Loading state %d", self.state);
    
    switch(self.state)
    {
        case PlayerStateCanStartRecording:
            [self setupBottomRecordingSession];
            [self startBottomRecordingSession];
            self.autosLabel.hidden = false;
            self.recordAutosControl.hidden = false;
            self.topVideoPlayButton.hidden = false;
            [self.bottomVideoRecordButton setImage: [UIImage imageNamed:@"video_rec"]];
            self.bottomVideoCancelButton.hidden = true;
            self.bottomVideoTimeLabel.hidden = true;
            break;
        case PlayerStateCanStopRecording:
            self.bottomVideoTimeLabel.hidden = false;
            self.autosLabel.hidden = true;
            self.recordAutosControl.hidden = true;
            self.recordStartTime = [[NSDate alloc] init];
            if(startVideoWithRecord)
            {
                [self startTopPlayback];
                self.videoPlaybackElapsedTime = 0;
            }
            [self startRecording];
            [self.bottomVideoRecordButton setImage: [UIImage imageNamed:@"video_stop"]];
            break;
        case PlayerStateCanStartPlayback:
            [self setupBottomPlayback];
            [self.bottomVideoRecordButton setImage: [UIImage imageNamed:@"video_play"]];
            playbackLength = recordingLength;
            [self updatePlaybackTimeLabel:nil];
            self.bottomVideoCancelButton.hidden = false;
            break;
        case PlayerStateCanStopPlayback:
            [self startPlayback];
            [self.bottomVideoRecordButton setImage: [UIImage imageNamed:@"video_stop"]];
            break;
            
    }
}

- (void)loadCanRecordState
{
    
}

- (void)updateRecordingTimeLabel:(id)sender
{
    int recordingMinutes = recordingLength / 60;
    int recordingSeconds = recordingLength % 60;
    
    self.bottomVideoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", recordingMinutes, recordingSeconds];
    recordingLength++;
}

- (void)updatePlaybackTimeLabel:(id)sender
{
    int recordingMinutes = playbackLength / 60;
    int recordingSeconds = playbackLength % 60;

    self.bottomVideoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", recordingMinutes, recordingSeconds];
    if(sender)
    {
        playbackLength--;
    }
}

- (void)recordingDidFinishPlaying:(id)sender
{
    //the video has finished playing - let's stop the playback
    if (self.state == PlayerStateCanStopPlayback)
    {
        [self handleBottomVideoRecordButtonTap:nil];
    }
}

- (void)videoDidFinishPlaying:(id)sender
{
    //the video has finished playing - let's stop the playback
    if (self.state == PlayerStateCanStopRecording && finishRecordWithVideo)
    {
        [self handleBottomVideoRecordButtonTap:nil];
    }
}

-(IBAction) autoRecordingSettingsChanged: (id) sender
{
    switch(self.recordAutosControl.selectedSegmentIndex)
    {
        case 0:
            startVideoWithRecord = true;
            finishRecordWithVideo = false;
            break;
        case 1:
            startVideoWithRecord = false;
            finishRecordWithVideo = true;
            break;
        case 2:
            startVideoWithRecord = true;
            finishRecordWithVideo = true;
            break;
        case 3:
            startVideoWithRecord = false;
            finishRecordWithVideo = false;
            break;
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.topVideoPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.topVideoPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"top video is ready to play");
        } else if (self.topVideoPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"top video cannot play, error: %@", self.topVideoPlayer.error);
        }
    }
}

@end
