 import UIKit
 protocol ColorTheme{
  	var bgColor: UIColor{get}
	var secondBgColor: UIColor{get}
	var optionsBgColor: UIColor{get}
	var blockLoadingColor: UIColor{get}
	var labelColor: UIColor{get}
	var secondarylabelcolor: UIColor{get}
	var primaryColor: UIColor{get}
	var inputNormalColor: UIColor{get}
	var errorTextColor: UIColor{get}
	var buttonTextColor: UIColor{get}
	var buttonColorNormal: UIColor{get}
	var buttonColorPressed: UIColor{get}
	var buttonColorDisable: UIColor{get}
	var buttonColorCancel: UIColor{get}
	var buttonColorCancelPressed: UIColor{get}
	var toastBg: UIColor{get}
	var maskColor: UIColor{get}
	var inputBgColor: UIColor{get}
	var b321aCardBigBallColorStar: UIColor{get}
	var b321aCardBigBallColorEnd: UIColor{get}
	var b321aCardSmallBallColor: UIColor{get}
	var b321aCardIconBgColor: UIColor{get}
	var iconUncheckColor: UIColor{get}
  }

struct LightColorTheme:ColorTheme{
 	let bgColor: UIColor = UIColor(hex: "#FFFCFCFC")
	let secondBgColor: UIColor = UIColor(hex: "#FAFFFFFF")
	let optionsBgColor: UIColor = UIColor(hex: "#FFededed")
	let blockLoadingColor: UIColor = UIColor(hex: "#FFE6EBF2")
	let labelColor: UIColor = UIColor(hex: "#FF141414")
	let secondarylabelcolor: UIColor = UIColor(hex: "#FF8C8C8C")
	let primaryColor: UIColor = UIColor(hex: "#FF8183DB")
	let inputNormalColor: UIColor = UIColor(hex: "#FFC9C9C9")
	let errorTextColor: UIColor = UIColor(hex: "#FFF56666")
	let buttonTextColor: UIColor = UIColor(hex: "#FFFFFFFF")
	let buttonColorNormal: UIColor = UIColor(hex: "#FF8183DB")
	let buttonColorPressed: UIColor = UIColor(hex: "#FF7375C4")
	let buttonColorDisable: UIColor = UIColor(hex: "#FFE0E5EC")
	let buttonColorCancel: UIColor = UIColor(hex: "#1A8183DB")
	let buttonColorCancelPressed: UIColor = UIColor(hex: "#408183DB")
	let toastBg: UIColor = UIColor(hex: "#CC000000")
	let maskColor: UIColor = UIColor(hex: "#99000000")
	let inputBgColor: UIColor = UIColor(hex: "#FFF5F5FF")
	let b321aCardBigBallColorStar: UIColor = UIColor(hex: "#FFFCFEFF")
	let b321aCardBigBallColorEnd: UIColor = UIColor(hex: "#FFF0E5FA")
	let b321aCardSmallBallColor: UIColor = UIColor(hex: "#FFECD5FF")
	let b321aCardIconBgColor: UIColor = UIColor(hex: "#FFF5F5FF")
	let iconUncheckColor: UIColor = UIColor(hex: "#FFE0E5EC")
 }

struct DarkColorTheme:ColorTheme{
 	let bgColor: UIColor = UIColor(hex: "#FF1C1A1D")
	let secondBgColor: UIColor = UIColor(hex: "#FF282540")
	let optionsBgColor: UIColor = UIColor(hex: "#FF75658B")
	let blockLoadingColor: UIColor = UIColor(hex: "#FF323150")
	let labelColor: UIColor = UIColor(hex: "#FFF9F2FF")
	let secondarylabelcolor: UIColor = UIColor(hex: "#FFB0B0B0")
	let primaryColor: UIColor = UIColor(hex: "#FF7679EE")
	let inputNormalColor: UIColor = UIColor(hex: "#FF8a8488")
	let errorTextColor: UIColor = UIColor(hex: "#FFFF6262")
	let buttonTextColor: UIColor = UIColor(hex: "#FFFFFFFF")
	let buttonColorNormal: UIColor = UIColor(hex: "#FF7679EE")
	let buttonColorPressed: UIColor = UIColor(hex: "#FF6064DF")
	let buttonColorDisable: UIColor = UIColor(hex: "#FF535266")
	let buttonColorCancel: UIColor = UIColor(hex: "#1A7679EE")
	let buttonColorCancelPressed: UIColor = UIColor(hex: "#407679EE")
	let toastBg: UIColor = UIColor(hex: "#CC000000")
	let maskColor: UIColor = UIColor(hex: "#99000000")
	let inputBgColor: UIColor = UIColor(hex: "#FF323150")
	let b321aCardBigBallColorStar: UIColor = UIColor(hex: "#7E1C45B4")
	let b321aCardBigBallColorEnd: UIColor = UIColor(hex: "#7F775CE2")
	let b321aCardSmallBallColor: UIColor = UIColor(hex: "#FF765BBB")
	let b321aCardIconBgColor: UIColor = UIColor(hex: "#FF323150")
	let iconUncheckColor: UIColor = UIColor(hex: "#FF4F507F")
 }