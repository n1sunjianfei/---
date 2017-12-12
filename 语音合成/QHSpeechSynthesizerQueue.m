//
//  QHSpeechSynthesizerQueue
//  JFDynamicClipImage
//
//  Created by JianF.Sun on 2017/12/11.
//  Copyright © 2017年 yasic. All rights reserved.
//

#import "QHSpeechSynthesizerQueue.h"

@interface QHSpeechSynthesizerQueue()
@property(nonatomic,strong) NSMutableArray *queue;
@property(nonatomic,strong) AVSpeechSynthesizer *synthesizer;
@property(nonatomic,assign) BOOL play;
@property(nonatomic,strong) AVAudioSession *audioSession;

@end
@implementation QHSpeechSynthesizerQueue


-(instancetype)init{
    self = [super init];
    if (self){
        self.queue = [[NSMutableArray alloc] init];
        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
        [self.synthesizer setDelegate:self];
        self.play = true;
        self.audioSession = [AVAudioSession sharedInstance];
        [self.audioSession setActive:YES error:nil];
        self.duckOthers = YES;
    }
    return self;
}

-(void)readLast:(NSString*)message withLanguage:(NSString*)language andRate:(float)rate{
    AVSpeechUtterance *utterance = [self createUtteranceWithString:message andLanguage:language andRate:rate];
    [self.queue addObject:utterance];
    [self next];
}

-(void)readNext:(NSString*)message withLanguage:(NSString*)language andRate:(float)rate andClearQueue:(BOOL)clearQueue{
    if (clearQueue)
        [self clearQueue];
    AVSpeechUtterance *utterance = [self createUtteranceWithString:message andLanguage:language andRate:rate];
    [self.queue insertObject:utterance atIndex:0];
    [self next];
}

-(void)readImmediately:(NSString*)message withLanguage:(NSString*)language andRate:(float)rate andClearQueue:(BOOL)clearQueue{
    if (clearQueue){
        [self clearQueue];
    }
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    AVSpeechUtterance *utterance = [self createUtteranceWithString:message andLanguage:language andRate:rate];
    [self.synthesizer speakUtterance:utterance];
}

-(void)setDuckOthers:(BOOL)duck{
    _duckOthers = duck;
    if (duck)
        [self.audioSession setCategory:AVAudioSessionCategoryPlayback
                       withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    else
        [self.audioSession setCategory:AVAudioSessionCategoryPlayback
                       withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
}

#pragma mark Internal
-(void)next{
    if (self.play && [self.queue count] > 0 && ![self.synthesizer isSpeaking]){
        AVSpeechUtterance *utterance = [self.queue firstObject];
        [self.queue removeObjectAtIndex:0];
        [self.synthesizer speakUtterance:utterance];
    }
}

-(AVSpeechUtterance*)createUtteranceWithString:(NSString*)message andLanguage:(NSString*)language andRate:(float)rate{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
    [utterance setRate:rate];
    [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:language]];
    [utterance setPreUtteranceDelay:[self preDelay]];
    [utterance setPostUtteranceDelay:[self postDelay]];
    return utterance;
}

#pragma mark Controls
-(void)resume{
    self.play = true;
    if (![self.synthesizer continueSpeaking])
        [self next];
}

-(void)pause{
    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    self.play = false;
}

-(void)pauseAfterCurrent{
    self.play = false;
}

-(void)stop{
    [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    self.play = false;
    [self clearQueue];
}

-(void)stopAfterCurrent{
    self.play = false;
    [self clearQueue];
}

-(void)clearQueue{
    [self.queue removeAllObjects];
}

#pragma mark AVSpeechSynthesizerDelegate Protocol
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueDidStartTalking:)])
        [self.delegate speechSynthesizerQueueDidStartTalking:self];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueDidPauseTalking:)])
        [self.delegate speechSynthesizerQueueDidPauseTalking:self];
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueDidContinueTalking:)])
        [self.delegate speechSynthesizerQueueDidContinueTalking:self];
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueDidCancelTalking:)])
        [self.delegate speechSynthesizerQueueDidCancelTalking:self];
    
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueWillStartTalking:)])
        [self.delegate speechSynthesizerQueueWillStartTalking:self];
    
}
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechSynthesizerQueueDidFinishTalking:)])
        [self.delegate speechSynthesizerQueueDidFinishTalking:self];
    [self next];
}

@end
