//
//  AppStep.swift
//  FondationProj
//
//  Created by baedy on 2020/05/06.
//  Copyright © 2020 baedy. All rights reserved.
//

import RxFlow
import Photos

enum AppStep: Step {
    case initialize
    
    case multiSelectTable
    case multiSelectCollection
    case linkCollection
    case horizontalStackScroll
    case webSchemeTest
    case rotate
    case playerSlider
    case filterSlider
    case rotateStackScroll
    case toastWithView
    
    case imageZoom
    
    case close
    case assetImageZoom([PHAsset], Int)
    
    
    
    case linkImageZoom([URL], Int)
}
