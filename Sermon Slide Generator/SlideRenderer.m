//
//  SlideRenderer.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/13/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "SlideRenderer.h"
#import "SlideContainer.h"
#import "SlideElement.h"
#import <Cocoa/Cocoa.h>

@implementation SlideRenderer

- (NSImage *)imageForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize
{
	NSImage * image = [[NSImage alloc] initWithSize:renderSize];
	[image lockFocus];

	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

	CGContextSaveGState(context);

//	CGContextTranslateCTM(context, 0, renderSize.height);
//	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
	// over-fill with black (to bleed and avoid 1px lines around the edge
	CGContextFillRect(context, CGRectMake(0, 0, renderSize.width * 2, renderSize.height * 2));

	CGFloat existingBottomElementHeight = 0;
	for (SlideElement * element in slide.slideElements)
	{
		if (element.verticalAlignment == SlideVerticalAlignmentMiddle)
			[self _renderMiddleSlideElement:element renderSize:renderSize context:context];
		else if (element.verticalAlignment == SlideVerticalAlignmentBottom)
		{
			CGSize elementRenderSize = [self _renderBottomSlideElement:element renderSize:renderSize bottomOffset:existingBottomElementHeight context:context];
			existingBottomElementHeight += elementRenderSize.height;
		}

	}

	CGContextRestoreGState(context);

	[image unlockFocus];
    return image;
}

- (CGSize)_renderMiddleSlideElement:(SlideElement *)element renderSize:(CGSize)renderSize context:(CGContextRef)context
{
	if (element.elementType == SlideElementTypeImage)
	{
		NSImage * elementImage = [[NSImage alloc] initWithContentsOfFile:element.imageFilePath];
		NSData * imageData = [elementImage TIFFRepresentation];
		NSBitmapImageRep * imageRep = [NSBitmapImageRep imageRepWithData:imageData];
		NSNumber * compressionFactor = [NSNumber numberWithFloat:1.0];
		NSDictionary * imageProps = [NSDictionary dictionaryWithObject:compressionFactor forKey:NSImageCompressionFactor];
		imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

		// we need to render the thumbnail here in the correct aspect
		CGSize targetSize = elementImage.size;
		CGPoint renderOffset = CGPointMake(0, 0);

		float targetRatio = targetSize.width / targetSize.height; // the ratio of width/height of the video
		float thumbnailRatio = renderSize.width / renderSize.height; // the ratio of width/height of the thumbnail "frame"

		if (targetRatio == thumbnailRatio) // if they're the same ratio, just scale it
		{
			targetSize = renderSize;
		}
		else if (thumbnailRatio > targetRatio) // if thumbnail frame is wider than video
		{
			//float diffRatio = targetSize.height / thumbnailSize.height;

			//NSLog(@"(wide) diff: %f", diffRatio);

			targetSize.height = renderSize.height;
			targetSize.width = targetSize.height * targetRatio;

			renderOffset.x = (renderSize.width / 2) - (targetSize.width / 2);
		}
		else // if thumbnail frame is narrower than video
		{
			//float diffRatio = targetSize.width / thumbnailSize.width;

			targetRatio = targetSize.height / targetSize.width;

			//NSLog(@"(narrow) diff: %f", diffRatio);

			targetSize.width = renderSize.width;
			targetSize.height = targetSize.width * targetRatio;

			renderOffset.y = (renderSize.height / 2) - (targetSize.height / 2);
		}

		renderOffset.x = renderOffset.x - 1;
		renderOffset.y = renderOffset.y - 1;
		targetSize.width = targetSize.width + 2;
		targetSize.height = targetSize.height + 2;

		CGImageSourceRef source;

		source = CGImageSourceCreateWithData((CFDataRef)[elementImage TIFFRepresentation], NULL);
		CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);

//		CGContextSaveGState(context);
//
//		CGContextTranslateCTM(context, 0, renderSize.height);
//		CGContextScaleCTM(context, 1.0, -1.0);

		CGContextDrawImage(context, CGRectMake(renderOffset.x, renderOffset.y, targetSize.width, targetSize.height), maskRef);

//		CGContextRestoreGState(context);

		return targetSize;
	}

	return CGSizeZero;
}

- (CGSize)_renderBottomSlideElement:(SlideElement *)element renderSize:(CGSize)renderSize bottomOffset:(CGFloat)bottomOffset context:(CGContextRef)context
{
	if (element.elementType == SlideElementTypeText)
	{
		float xPos = 0;//(canvasSize.width - canvasSizeWithPadding.width) / 2;
		float yPos = 0;//(canvasSize.height - canvasSizeWithPadding.height) / 2;

		// defaults
		NSString * textFontName = @"HelveticaNeue-Bold";
		float origSize = 55;
		CTTextAlignment theAlignment = kCTCenterTextAlignment;
		NSColor * textColor = [NSColor whiteColor];
		NSColor * textShadowColor = [NSColor blackColor];
		CGSize textShadowOffset = CGSizeMake(1, 1);
		float textShadowBlur = 1;
		float textShadowOpacity = 1.0;
		CGFloat textLineSpacing = 1.0;
		BOOL shouldAutosizeText = NO;
		NSString * textToRender = element.textValue;

		if (element.fontName)
		{
			textFontName = element.fontName;
		}
		if (element.fontSize)
		{
			origSize = element.fontSize;
		}

		CGFloat marginTop = 5;
		CGFloat marginBottom = 5 + bottomOffset;
		CGFloat marginLeft = 5;
		CGFloat marginRight = 5;

		if (element.textAlignment == NSLeftTextAlignment)
		{
			theAlignment = kCTLeftTextAlignment;
		}
		else if (element.textAlignment == NSRightTextAlignment)
		{
			theAlignment = kCTRightTextAlignment;
		}

		CGContextSetFillColorWithColor(context, [textColor CGColor]);

		// use colorWithAlphaComponent: to get the shadow opacity into the color itself, as there's no separate option for opacity.
		CGContextSetShadowWithColor(context, textShadowOffset, textShadowBlur, [textShadowColor colorWithAlphaComponent:textShadowOpacity].CGColor);


		float convertedMarginTop = [self actualPixelHeightForMarginHeight:marginTop atSize:renderSize];
		float convertedMarginBottom = [self actualPixelHeightForMarginHeight:marginBottom atSize:renderSize];
		float convertedMarginLeft = [self actualPixelWidthForMarginWidth:marginLeft atSize:renderSize];
		float convertedMarginRight = [self actualPixelWidthForMarginWidth:marginRight atSize:renderSize];


		CGRect convertedMarginRect = CGRectMake(convertedMarginLeft, convertedMarginTop, renderSize.width - convertedMarginLeft - convertedMarginRight, renderSize.height - convertedMarginTop - convertedMarginBottom);
		if (convertedMarginRect.origin.x > convertedMarginRect.origin.x + convertedMarginRect.size.width)
		{
			float newConvertedMarginLeft = renderSize.width - convertedMarginRight;
			float newConvertedMarginRight = renderSize.width - convertedMarginLeft;

			convertedMarginLeft = newConvertedMarginLeft;
			convertedMarginRight = newConvertedMarginRight;
		}

		if (convertedMarginRect.origin.y > convertedMarginRect.origin.y + convertedMarginRect.size.height)
		{
			float newConvertedMarginTop = renderSize.height - convertedMarginTop;
			float newConvertedMarginBottom = renderSize.height - convertedMarginBottom;

			convertedMarginTop = newConvertedMarginBottom;
			convertedMarginBottom = newConvertedMarginTop;
		}



		float adjustedSize = [self actualFontSizeForText:textToRender withFont:[NSFont fontWithName:textFontName size:origSize] withOriginalSize:origSize imageSize:CGSizeMake(renderSize.width, renderSize.height) innerSizeWithMargins:CGSizeMake(renderSize.width - convertedMarginLeft - convertedMarginRight - (renderSize.width * 0.01), renderSize.height - convertedMarginTop - convertedMarginBottom) shouldAutosizeText:shouldAutosizeText];

		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) textFontName, adjustedSize, NULL);



		CGFloat minLineHeight = textLineSpacing + adjustedSize - 1;
		CGFloat maxLineHeight = textLineSpacing + adjustedSize + 1;

		CFIndex theNumberOfSettings = 3;
		CTParagraphStyleSetting theSettings[3] =
		{
			{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment },
			{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight },
			{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight }
		};

		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);

		NSDictionary * attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 (__bridge id)font, (NSString *)kCTFontAttributeName,
										 textColor, (NSString *)kCTForegroundColorAttributeName,
										 (__bridge id)paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
										 nil];


		NSAttributedString * stringToDraw = [[NSAttributedString alloc] initWithString:textToRender attributes:attributesDict];
		if (!stringToDraw)
		{
			stringToDraw = [[NSAttributedString alloc] initWithString:@" "];
		}

		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);

		NSInteger textLength = [stringToDraw length];
		CFRange range;
		CGSize constraint = CGSizeMake(renderSize.width - convertedMarginLeft - convertedMarginRight, renderSize.height - convertedMarginTop - convertedMarginBottom);

		CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);

		// add some extra padding to the text size, to make sure all of it fits.
		textSize.height = textSize.height + (textSize.height * 0.05);
		textSize.width = textSize.width + (textSize.width * 0.05);

		if (element)
		{
			if (element.verticalAlignment == SlideVerticalAlignmentBottom)
			{
				yPos = convertedMarginBottom;
			}
			else if (element.verticalAlignment == SlideVerticalAlignmentTop)
			{
				yPos = renderSize.height - convertedMarginTop - textSize.height;
			}
			else
			{
				float boxHeight = renderSize.height - convertedMarginTop - convertedMarginBottom;

				yPos = (boxHeight * 0.5) - (textSize.height * 0.5) + convertedMarginBottom;
			}
		}
		else
		{
			yPos = (renderSize.height * 0.5) - (textSize.height * 0.5);
		}


		if (theAlignment == kCTLeftTextAlignment)
		{
			xPos = convertedMarginLeft;
		}
		else if (theAlignment == kCTCenterTextAlignment)
		{
			xPos = convertedMarginLeft + (constraint.width / 2) - (textSize.width / 2);
		}
		else if (theAlignment == kCTRightTextAlignment)
		{
			xPos = renderSize.width - textSize.width - convertedMarginRight;
		}


		//Create Frame
		CGMutablePathRef path = CGPathCreateMutable();

		CGPathAddRect(path, NULL, CGRectMake(xPos, yPos, textSize.width, textSize.height));

		CFRange outputRange;
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
		CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringToDraw.length), nil, constraint, &outputRange);

		//Draw Frame
		CTFrameDraw(frame, context);
		
		CFRelease(path);
		CFRelease(frame);
		CFRelease(framesetter);
		
		CFRelease(font);
		
		CFRelease(paragraphStyle);

		return CGSizeMake(frameSize.width, (frameSize.height / 2));
	}

	return CGSizeZero;
}


- (NSImage *)imageMaskForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize
{
	NSImage * image = [[NSImage alloc] initWithSize:renderSize];
	[image lockFocus];

	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

	CGContextSaveGState(context);

	//	CGContextTranslateCTM(context, 0, renderSize.height);
	//	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
	// over-fill with black (to bleed and avoid 1px lines around the edge
	CGContextFillRect(context, CGRectMake(0, 0, renderSize.width * 2, renderSize.height * 2));

	CGFloat existingBottomElementHeight = 0;
	for (SlideElement * element in slide.slideElements)
	{
		if (element.verticalAlignment == SlideVerticalAlignmentMiddle)
			[self _renderMaskMiddleSlideElement:element renderSize:renderSize context:context];
		else if (element.verticalAlignment == SlideVerticalAlignmentBottom)
		{
			CGSize elementRenderSize = [self _renderMaskBottomSlideElement:element renderSize:renderSize bottomOffset:existingBottomElementHeight context:context];
			existingBottomElementHeight += elementRenderSize.height;
		}

	}

	CGContextRestoreGState(context);

	[image unlockFocus];
	return image;
}

- (CGSize)_renderMaskMiddleSlideElement:(SlideElement *)element renderSize:(CGSize)renderSize context:(CGContextRef)context
{
	if (element.elementType == SlideElementTypeImage)
	{
		NSImage * elementImage = [[NSImage alloc] initWithContentsOfFile:element.imageFilePath];
		NSData * imageData = [elementImage TIFFRepresentation];
		NSBitmapImageRep * imageRep = [NSBitmapImageRep imageRepWithData:imageData];
		NSNumber * compressionFactor = [NSNumber numberWithFloat:1.0];
		NSDictionary * imageProps = [NSDictionary dictionaryWithObject:compressionFactor forKey:NSImageCompressionFactor];
		imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

		// we need to render the thumbnail here in the correct aspect
		CGSize targetSize = elementImage.size;
		CGPoint renderOffset = CGPointMake(0, 0);

		float targetRatio = targetSize.width / targetSize.height; // the ratio of width/height of the video
		float thumbnailRatio = renderSize.width / renderSize.height; // the ratio of width/height of the thumbnail "frame"

		if (targetRatio == thumbnailRatio) // if they're the same ratio, just scale it
		{
			targetSize = renderSize;
		}
		else if (thumbnailRatio > targetRatio) // if thumbnail frame is wider than video
		{
			//float diffRatio = targetSize.height / thumbnailSize.height;

			//NSLog(@"(wide) diff: %f", diffRatio);

			targetSize.height = renderSize.height;
			targetSize.width = targetSize.height * targetRatio;

			renderOffset.x = (renderSize.width / 2) - (targetSize.width / 2);
		}
		else // if thumbnail frame is narrower than video
		{
			//float diffRatio = targetSize.width / thumbnailSize.width;

			targetRatio = targetSize.height / targetSize.width;

			//NSLog(@"(narrow) diff: %f", diffRatio);

			targetSize.width = renderSize.width;
			targetSize.height = targetSize.width * targetRatio;

			renderOffset.y = (renderSize.height / 2) - (targetSize.height / 2);
		}

		renderOffset.x = renderOffset.x - 1;
		renderOffset.y = renderOffset.y - 1;
		targetSize.width = targetSize.width + 2;
		targetSize.height = targetSize.height + 2;
//
//		CGImageSourceRef source;
//
//		source = CGImageSourceCreateWithData((CFDataRef)[elementImage TIFFRepresentation], NULL);
//		CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);

		//		CGContextSaveGState(context);
		//
		//		CGContextTranslateCTM(context, 0, renderSize.height);
		//		CGContextScaleCTM(context, 1.0, -1.0);



		CGContextSetFillColorWithColor(context, [NSColor whiteColor].CGColor);
		// fill entire area with white
		CGContextFillRect(context, CGRectMake(0, 0, renderSize.width, renderSize.height));

		//CGContextDrawImage(context, CGRectMake(renderOffset.x, renderOffset.y, targetSize.width, targetSize.height), maskRef);

		//		CGContextRestoreGState(context);

		return targetSize;
	}

	return CGSizeZero;
}

- (CGSize)_renderMaskBottomSlideElement:(SlideElement *)element renderSize:(CGSize)renderSize bottomOffset:(CGFloat)bottomOffset context:(CGContextRef)context
{
	if (element.elementType == SlideElementTypeText)
	{
		float xPos = 0;//(canvasSize.width - canvasSizeWithPadding.width) / 2;
		float yPos = 0;//(canvasSize.height - canvasSizeWithPadding.height) / 2;

		// defaults
		NSString * textFontName = @"HelveticaNeue-Bold";
		float origSize = 55;
		CTTextAlignment theAlignment = kCTCenterTextAlignment;
		NSColor * textColor = [NSColor whiteColor];
		NSColor * textShadowColor = [NSColor whiteColor];
		CGSize textShadowOffset = CGSizeMake(1, 1);
		float textShadowBlur = 1;
		float textShadowOpacity = 1.0;
		CGFloat textLineSpacing = 1.0;
		BOOL shouldAutosizeText = NO;
		NSString * textToRender = element.textValue;

		if (element.fontName)
		{
			textFontName = element.fontName;
		}
		if (element.fontSize)
		{
			origSize = element.fontSize;
		}

		CGFloat marginTop = 5;
		CGFloat marginBottom = 5 + bottomOffset;
		CGFloat marginLeft = 5;
		CGFloat marginRight = 5;

		if (element.textAlignment == NSLeftTextAlignment)
		{
			theAlignment = kCTLeftTextAlignment;
		}
		else if (element.textAlignment == NSRightTextAlignment)
		{
			theAlignment = kCTRightTextAlignment;
		}

		CGContextSetFillColorWithColor(context, [textColor CGColor]);

		// use colorWithAlphaComponent: to get the shadow opacity into the color itself, as there's no separate option for opacity.
		CGContextSetShadowWithColor(context, textShadowOffset, textShadowBlur, [textShadowColor colorWithAlphaComponent:textShadowOpacity].CGColor);


		float convertedMarginTop = [self actualPixelHeightForMarginHeight:marginTop atSize:renderSize];
		float convertedMarginBottom = [self actualPixelHeightForMarginHeight:marginBottom atSize:renderSize];
		float convertedMarginLeft = [self actualPixelWidthForMarginWidth:marginLeft atSize:renderSize];
		float convertedMarginRight = [self actualPixelWidthForMarginWidth:marginRight atSize:renderSize];


		CGRect convertedMarginRect = CGRectMake(convertedMarginLeft, convertedMarginTop, renderSize.width - convertedMarginLeft - convertedMarginRight, renderSize.height - convertedMarginTop - convertedMarginBottom);
		if (convertedMarginRect.origin.x > convertedMarginRect.origin.x + convertedMarginRect.size.width)
		{
			float newConvertedMarginLeft = renderSize.width - convertedMarginRight;
			float newConvertedMarginRight = renderSize.width - convertedMarginLeft;

			convertedMarginLeft = newConvertedMarginLeft;
			convertedMarginRight = newConvertedMarginRight;
		}

		if (convertedMarginRect.origin.y > convertedMarginRect.origin.y + convertedMarginRect.size.height)
		{
			float newConvertedMarginTop = renderSize.height - convertedMarginTop;
			float newConvertedMarginBottom = renderSize.height - convertedMarginBottom;

			convertedMarginTop = newConvertedMarginBottom;
			convertedMarginBottom = newConvertedMarginTop;
		}



		float adjustedSize = [self actualFontSizeForText:textToRender withFont:[NSFont fontWithName:textFontName size:origSize] withOriginalSize:origSize imageSize:CGSizeMake(renderSize.width, renderSize.height) innerSizeWithMargins:CGSizeMake(renderSize.width - convertedMarginLeft - convertedMarginRight - (renderSize.width * 0.01), renderSize.height - convertedMarginTop - convertedMarginBottom) shouldAutosizeText:shouldAutosizeText];

		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) textFontName, adjustedSize, NULL);



		CGFloat minLineHeight = textLineSpacing + adjustedSize - 1;
		CGFloat maxLineHeight = textLineSpacing + adjustedSize + 1;

		CFIndex theNumberOfSettings = 3;
		CTParagraphStyleSetting theSettings[3] =
		{
			{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment },
			{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight },
			{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight }
		};

		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);

		NSDictionary * attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 (__bridge id)font, (NSString *)kCTFontAttributeName,
										 textColor, (NSString *)kCTForegroundColorAttributeName,
										 (__bridge id)paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
										 nil];


		NSAttributedString * stringToDraw = [[NSAttributedString alloc] initWithString:textToRender attributes:attributesDict];
		if (!stringToDraw)
		{
			stringToDraw = [[NSAttributedString alloc] initWithString:@" "];
		}

		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);

		NSInteger textLength = [stringToDraw length];
		CFRange range;
		CGSize constraint = CGSizeMake(renderSize.width - convertedMarginLeft - convertedMarginRight, renderSize.height - convertedMarginTop - convertedMarginBottom);

		CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);

		// add some extra padding to the text size, to make sure all of it fits.
		textSize.height = textSize.height + (textSize.height * 0.05);
		textSize.width = textSize.width + (textSize.width * 0.05);

		if (element)
		{
			if (element.verticalAlignment == SlideVerticalAlignmentBottom)
			{
				yPos = convertedMarginBottom;
			}
			else if (element.verticalAlignment == SlideVerticalAlignmentTop)
			{
				yPos = renderSize.height - convertedMarginTop - textSize.height;
			}
			else
			{
				float boxHeight = renderSize.height - convertedMarginTop - convertedMarginBottom;

				yPos = (boxHeight * 0.5) - (textSize.height * 0.5) + convertedMarginBottom;
			}
		}
		else
		{
			yPos = (renderSize.height * 0.5) - (textSize.height * 0.5);
		}


		if (theAlignment == kCTLeftTextAlignment)
		{
			xPos = convertedMarginLeft;
		}
		else if (theAlignment == kCTCenterTextAlignment)
		{
			xPos = convertedMarginLeft + (constraint.width / 2) - (textSize.width / 2);
		}
		else if (theAlignment == kCTRightTextAlignment)
		{
			xPos = renderSize.width - textSize.width - convertedMarginRight;
		}


		//Create Frame
		CGMutablePathRef path = CGPathCreateMutable();

		CGPathAddRect(path, NULL, CGRectMake(xPos, yPos, textSize.width, textSize.height));

		CFRange outputRange;
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
		CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringToDraw.length), nil, constraint, &outputRange);

		//Draw Frame
		CTFrameDraw(frame, context);

		CFRelease(path);
		CFRelease(frame);
		CFRelease(framesetter);

		CFRelease(font);
		
		CFRelease(paragraphStyle);
		
		return CGSizeMake(frameSize.width, (frameSize.height / 2));
	}
	
	return CGSizeZero;
}


- (double)textScaleRatioFromSize:(CGSize)thumbnailSize;
{
	return 1024.f / thumbnailSize.width;
}

- (CGFloat)actualFontSizeForText:(NSString *)text withFont:(NSFont *)aFont withOriginalSize:(CGFloat)originalSize imageSize:(CGSize)thumbSize innerSizeWithMargins:(CGSize)innerSize shouldAutosizeText:(BOOL)shouldAutosizeText;
{
	float scaledSize = originalSize / [self textScaleRatioFromSize:innerSize];

	scaledSize = floorf(scaledSize);

	if (!shouldAutosizeText)
	{
		return scaledSize;
	}

	aFont = [NSFont fontWithName:[aFont fontName] size:scaledSize];//[aFont fontWithSize:scaledSize];

	float longestLineWidth = 1;

	NSArray * textComponents = [text componentsSeparatedByString:@"\n"];

	if ([textComponents count] < 2 || [text length] < 2)
	{
		NSString * fontName = [aFont fontName];

		//  creating and formatting CFMutableAttributedString
		CFMutableAttributedStringRef attrStr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), (CFStringRef) text);
		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, scaledSize, NULL);
		CTTextAlignment alignment = kCTJustifiedTextAlignment;
		CTParagraphStyleSetting _settings[] = { {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
		CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
		CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
		CFRelease(paragraphStyle);
		CFRelease(font);

		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
		CFRelease(attrStr);

		NSInteger textLength = [text length];
		CFRange range;
		CGFloat maxWidth  = 1000000;
		CGFloat maxHeight = 1000000;
		CGSize constraint = CGSizeMake(maxWidth, maxHeight);

		CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);

		if (textSize.width + (textSize.width * 0.02) > longestLineWidth)
			longestLineWidth = textSize.width + (textSize.width * 0.02);

		CFRelease(framesetter);
	}
	else
	{
		for (NSString * line in textComponents)
		{
			NSString * fontName = [aFont fontName];

			//  creating and formatting CFMutableAttributedString
			CFMutableAttributedStringRef attrStr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
			CFAttributedStringReplaceString (attrStr, CFRangeMake(0, 0), (CFStringRef) line);
			CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, scaledSize, NULL);
			CTTextAlignment alignment = kCTJustifiedTextAlignment;
			CTParagraphStyleSetting _settings[] = { {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
			CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
			CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTParagraphStyleAttributeName, paragraphStyle);
			CFAttributedStringSetAttribute(attrStr, CFRangeMake(0, CFAttributedStringGetLength(attrStr)), kCTFontAttributeName, font);
			CFRelease(paragraphStyle);
			CFRelease(font);

			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
			CFRelease(attrStr);

			NSInteger textLength = [line length];
			CFRange range;
			CGFloat maxWidth  = 1000000;
			CGFloat maxHeight = 1000000;
			CGSize constraint = CGSizeMake(maxWidth, maxHeight);

			CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);

			if (textSize.width + (textSize.width * 0.02) > longestLineWidth)
				longestLineWidth = textSize.width + (textSize.width * 0.02);

			CFRelease(framesetter);
		}
	}

	float widthWithPadding = innerSize.width;

	if (longestLineWidth > widthWithPadding)
	{
		float ratio = widthWithPadding / longestLineWidth;
		scaledSize = scaledSize * ratio;
	}

	scaledSize = floorf(scaledSize);

	return scaledSize;
}


- (CGSize)shadowOffsetScaledFromOffset:(CGSize)oldOffset fromSize:(CGSize)thumbSize;
{
	CGSize newOffset = CGSizeMake(oldOffset.width / [self textScaleRatioFromSize:thumbSize], oldOffset.height / [self textScaleRatioFromSize:thumbSize]);

	return newOffset;
}


#pragma mark - Scaling

- (CGFloat)actualPixelWidthForMarginWidth:(CGFloat)marginWidth atSize:(CGSize)canvasSize;
{
	return ((marginWidth / 100) * canvasSize.height);
}

- (CGFloat)actualPixelHeightForMarginHeight:(CGFloat)marginHeight atSize:(CGSize)canvasSize;
{
	return ((marginHeight / 100) * canvasSize.height);
}

- (CGFloat)marginWidthForActualPixelWidth:(CGFloat)pixelWidth atSize:(CGSize)canvasSize;
{
	return (pixelWidth / canvasSize.height) * 100;
}

- (CGFloat)marginHeightForActualPixelHeight:(CGFloat)pixelHeight atSize:(CGSize)canvasSize;
{
	return (pixelHeight / canvasSize.height) * 100;
}


@end
