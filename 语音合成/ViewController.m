//
//  ViewController.m
//  语音合成
//
//  Created by 孙建飞 on 15/10/5.
//  Copyright (c) 2015年 sjf. All rights reserved.
//

#import "ViewController.h"
#import "QHSpeechSynthesizerQueue.h"
@interface ViewController ()<QHSpeechSynthesizerQueueDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)tap:(id)sender;
@property(nonatomic ,strong) AVSpeechSynthesizer *speechSynthesizer;
@property(nonatomic,strong) AVAudioSession *session;
@property (strong, nonatomic) QHSpeechSynthesizerQueue *speechSynthesizerQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.text = @"锦瑟无端五十弦,\n 一弦一柱思华年。\n 庄生晓梦迷蝴蝶，\n望帝春心托杜鹃。\n沧海月明珠有泪，\n蓝田日暖玉生烟。\n此情可待成追忆，\n只是当时已惘然。";
    self.speechSynthesizerQueue = [[QHSpeechSynthesizerQueue alloc] init];
    self.speechSynthesizerQueue.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 没封装的方法

- (IBAction)tap:(id)sender {
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc]init];
//    self.speechSynthesizer.delegate = self;
    AVSpeechUtterance *utt =[AVSpeechUtterance speechUtteranceWithString:self.textView.text];
    utt.voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];//设置语言
    self.session = [AVAudioSession sharedInstance];
    [self.session setActive:YES error:nil];
    [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    utt.rate = 0.6;
    [self.speechSynthesizer speakUtterance:utt];
    
}


#pragma mark - 封装之后的方法
- (IBAction)readLast:(id)sender {
    [self.speechSynthesizerQueue readLast:self.textView.text withLanguage:@"zh-CN" andRate:0.2f];
}

- (IBAction)readNext:(id)sender {
     [self.speechSynthesizerQueue readNext:@"第三段文字" withLanguage:@"zh-CN" andRate:0.2f andClearQueue:NO];
    [self.speechSynthesizerQueue readNext:@"第二段文字" withLanguage:@"zh-CN" andRate:0.2f andClearQueue:NO];
    
}

- (IBAction)readImmediately:(id)sender {
    [self.speechSynthesizerQueue readImmediately:@"立即阅读这段文字" withLanguage:@"zh-CN" andRate:0.2f andClearQueue:NO];
}
- (IBAction)stop:(id)sender {
    [self.speechSynthesizerQueue stop];
}
- (IBAction)stopAfterCurrent:(id)sender {
    [self.speechSynthesizerQueue stopAfterCurrent];
}
- (IBAction)pause:(id)sender {
    [self.speechSynthesizerQueue pause];
    
}
- (IBAction)pauseAfterCurrent:(id)sender {
    [self.speechSynthesizerQueue pauseAfterCurrent];
}
- (IBAction)resume:(id)sender {
    [self.speechSynthesizerQueue resume];
}

@end
