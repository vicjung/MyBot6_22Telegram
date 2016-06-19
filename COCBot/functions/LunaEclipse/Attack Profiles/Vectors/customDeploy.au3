; #FUNCTION# ====================================================================================================================
; Name ..........: customDeploy
; Description ...: Contains function to set up vectors for custom deployment
; Syntax ........:
; Parameters ....:
; Return values .: None
; Author ........: LunaEclipse(May, 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2016
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; Set up the vectors to deploy troops
Func customDeployVectors(ByRef $dropVectors, $listInfoDeploy, $sideCoords)
	If Not IsArray($dropVectors) Or Not IsArray($listInfoDeploy) Then Return
	
	ReDim $dropVectors[UBound($listInfoDeploy)][2]
	
	Local $kind, $waveNumber, $waveCount, $position, $remainingWaves, $waveDropAmount, $dropAmount, $barPosition
	Local $startPoint[2] = [0, 0], $endPoint[2] = [0, 0]
	Local $aDeployButtonPositions = getUnitLocationArray()
	Local $unitCount = unitCountArray()

	For $i = 0 To UBound($listInfoDeploy) - 1
		$kind = $listInfoDeploy[$i][0]
		$waveNumber = $listInfoDeploy[$i][2]
		$waveCount = $listInfoDeploy[$i][3]
		$position = $listInfoDeploy[$i][4]
		$remainingWaves = ($waveCount - $waveNumber) + 1

		If $kind <= $eKing Then
			$barPosition = $aDeployButtonPositions[$kind]

			If $barPosition <> -1 And Number($position) = 0 Then
				$waveDropAmount = calculateDropAmount($unitCount[$kind], $remainingWaves, $position)
				$unitCount[$kind] -= $waveDropAmount

				; Deployment Side - Left Half
				$dropAmount = Ceiling($waveDropAmount / 2)
				If $dropAmount > 0 Then
					$startPoint = convertToPoint($sideCoords[2][0], $sideCoords[2][1])
					$endPoint = convertToPoint($sideCoords[0][0], $sideCoords[0][1])
					addVector($dropVectors, $i, 0, $startPoint, $endPoint, $dropAmount)
					$waveDropAmount -= $dropAmount
				EndIf

				; Deployment Side - Right Half
				$dropAmount = $waveDropAmount
				If $dropAmount > 0 Then
					$startPoint = convertToPoint($sideCoords[2][0], $sideCoords[2][1])
					$endPoint = convertToPoint($sideCoords[4][0], $sideCoords[4][1])
					addVector($dropVectors, $i, 1, $startPoint, $endPoint, $dropAmount + 1)
					$waveDropAmount -= $dropAmount
				EndIf
			EndIf
		EndIf
	Next
EndFunc   ;==>dropRemainingTroopsCustom

; Set up the vectors to deploy troops
Func customDeployVectors(ByRef $dropVectors, $listInfoDeploy, $side)
	If Not IsArray($dropVectors) Or Not IsArray($listInfoDeploy) Then Return
	
	; Start the timer for drop point creation
	Local $hTimer = TimerInit()	
	SetLog("Calculating attack vectors for all troop deployments, please be patient...", $COLOR_PURPLE)

	ReDim $dropVectors[UBound($listInfoDeploy)][1]
	
	Local $kind, $waveNumber, $waveCount, $position, $remainingWaves, $dropAmount
	Local $aDeployButtonPositions = getUnitLocationArray()
	Local $unitCount = unitCountArray()

	For $i = 0 To UBound($listInfoDeploy) - 1
		$kind = $listInfoDeploy[$i][0]
		$waveNumber = $listInfoDeploy[$i][2]
		$waveCount = $listInfoDeploy[$i][3]
		$position = $listInfoDeploy[$i][4]
		$remainingWaves = ($waveCount - $waveNumber) + 1

		If $kind < $eLSpell And $aDeployButtonPositions[$kind] <> -1 Then
			Switch $kind
				Case $eKing, $eQueen, $eWarden, $eCastle
					addVector($dropVectors, $i, 0, $side, $directionRight, 0, 10)
				Case Else
					$dropAmount = calculateDropAmount($unitCount[$kind], $remainingWaves, $position)
					$unitCount[$kind] -= $dropAmount

					If $dropAmount > 0 Then
						If $position = 0 Or $dropAmount < $position Then $position = $dropAmount

						addVector($dropVectors, $i, 0, $side, $directionRight, 0, $position)
					EndIf					
			EndSwitch
		EndIf
	Next
	
	SetLog("Drop points created in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds!", $COLOR_PURPLE)
EndFunc   ;==>customDeployVectors