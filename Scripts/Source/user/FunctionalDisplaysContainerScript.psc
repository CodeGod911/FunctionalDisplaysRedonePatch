ScriptName FunctionalDisplaysContainerScript extends ObjectReference

;-- Structs -----------------------------------------
Struct FunctionalDisplaysStruct
	ObjectReference FDItemDisplayRef
	{ This will hold the currently displayed FDItem reference. }
	string FunctionalDisplaysNode
	{ The node the FDItem should be placed at. }
EndStruct

Struct FDMountStruct
	ObjectReference FDMountItemDisplayRef
	string FDHorizontalNode
EndStruct

Struct FDContainerItemType
	int formId
	Form formObj
	int count
EndStruct


;-- Properties --------------------------------------
Keyword Property FunctionalDisplaysKeyword Auto Const
Keyword Property FDHorizontalKeyword Auto Const
Keyword Property BobbleheadKeyword Auto Const
Keyword Property PerkMagKeyword Auto Const
Keyword Property ObjectTypeWeapon Auto Const
Keyword Property WeaponTypePistol Auto Const
Keyword Property WeaponTypeRifle Auto Const
Keyword Property WeaponTypeMelee1H Auto Const
Keyword Property WeaponTypeMelee2H Auto Const
Keyword Property WeaponTypeHeavyGun Auto Const
Keyword Property WeaponTypeHandToHand Auto Const
Keyword Property WeaponTypeMine Auto Const
Keyword Property WeaponTypeThrown Auto Const
Keyword Property WeaponTypeGrenade Auto Const
Keyword Property ObjectTypeAmmo Auto Const
Keyword Property ObjectTypeSyringerAmmo Auto Const
Keyword Property AnimFurnWater Auto Const
Keyword Property ObjectTypeWater Auto Const
Keyword Property ObjectTypeDrink Auto Const
Keyword Property ObjectTypeNukaCola Auto Const
Keyword Property ObjectTypeAlcohol Auto Const
Keyword Property ObjectTypeFood Auto Const
Keyword Property ObjectTypeStimpak Auto Const
Keyword Property ObjectTypeChem Auto Const
Keyword Property NotJunkJetAmmo Auto Const
Keyword Property BlockWorkshopInteractionKeyword Auto Const
Keyword Property FeaturedItem Auto Const
Form[] Property FDItemsInContainer Auto
Form[] Property FDMountItemsInContainer Auto
{ Array of current DisplayedItems that are in the container. }
FunctionalDisplaysStruct[] Property FunctionalDisplaysStructArray Auto
FDMountStruct[] Property FDMountStructArray Auto
FDContainerItemType[] Property FDContainerItemTypeArray Auto
{ Struct Array of each display DisplayedItem ref, and the node it should go to. }
Message Property FunctionalDisplaysContainerFullMessage Auto
Message Property FunctionalDisplaysContainerWrongMessage Auto

;-- Variables ---------------------------------------
bool AlreadyLoaded

;-- Functions ---------------------------------------

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	Debug.Trace("OnItemRemoved called!", 2) 
	If (akBaseItem.HasKeyword(FDHorizontalKeyword))
		int ItemIndex = FDMountItemsInContainer.find(akBaseItem, 0)
		If (ItemIndex >= 0)
			FDMountItemsInContainer.remove(ItemIndex, 1)
		EndIf
	EndIf
	If (akBaseItem.HasKeyword(FunctionalDisplaysKeyword) || akBaseItem.HasKeyword(BobbleheadKeyword) || akBaseItem.HasKeyword(PerkMagKeyword) || akBaseItem.HasKeyword(ObjectTypeWeapon) || akBaseItem.HasKeyword(WeaponTypePistol) || akBaseItem.HasKeyword(WeaponTypeRifle) || akBaseItem.HasKeyword(WeaponTypeMelee1H) || akBaseItem.HasKeyword(WeaponTypeMelee2H) || akBaseItem.HasKeyword(WeaponTypeHeavyGun) || akBaseItem.HasKeyword(WeaponTypeHandToHand) || akBaseItem.HasKeyword(WeaponTypeMine) || akBaseItem.HasKeyword(WeaponTypeThrown) || akBaseItem.HasKeyword(WeaponTypeGrenade) || akBaseItem.HasKeyword(ObjectTypeAmmo) || akBaseItem.HasKeyword(ObjectTypeSyringerAmmo) || akBaseItem.HasKeyword(AnimFurnWater) || akBaseItem.HasKeyword(ObjectTypeWater) || akBaseItem.HasKeyword(ObjectTypeDrink) || akBaseItem.HasKeyword(ObjectTypeNukaCola) || akBaseItem.HasKeyword(ObjectTypeAlcohol) || akBaseItem.HasKeyword(ObjectTypeFood) || akBaseItem.HasKeyword(ObjectTypeStimpak) || akBaseItem.HasKeyword(ObjectTypeChem) || akBaseItem.HasKeyword(NotJunkJetAmmo) || akBaseItem.HasKeyword(FeaturedItem))
		Self.DeleteFDItems()
		Self.DeleteFDMountItems()

		int count = 0
		while (count < FDContainerItemTypeArray.length)
			if (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
				FDContainerItemTypeArray[count].count -= aiItemCount
				if(FDContainerItemTypeArray[count].count <= 0)
					FDContainerItemTypeArray.Remove(count)
				endif
			endif
			count += 1
		endwhile

		Self.RecalculateFDItemsInContainer()

		Utility.Wait(0.1)
		Self.DisplayFDItems()
		Self.DisplayFDMountItems()
	EndIf
EndEvent

Function DisplayFDItems()
	Debug.Trace("DisplayFDItems called!", 2) 
	int MaxCount = FunctionalDisplaysStructArray.length
	If (MaxCount > 0)
		int Count = 0
		While (Count < MaxCount && Count < FDItemsInContainer.length)
			Debug.Trace("DisplayFDMountItems: Displaying: "+FDItemsInContainer[Count].GetFormID(), 2)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef = Self.PlaceAtNode(FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, FDItemsInContainer[Count], 1, False, False, False, True)
			Self.RegisterForRemoteEvent(FunctionalDisplaysStructArray[Count].FDItemDisplayRef, "OnContainerChanged")
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.AddKeyword(BlockWorkshopInteractionKeyword)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetNoFavorAllowed(True)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetPlayerHasTaken(True)
			Count += 1
		EndWhile
	EndIf
EndFunction

Event ObjectReference.OnContainerChanged(ObjectReference akSender, ObjectReference akNewContainer, ObjectReference akOldContainer)
	Self.UnregisterForRemoteEvent(akSender, "OnContainerChanged")
	Self.RemoveItem(akSender.GetBaseObject(), 1, False, None)
	akSender.RemoveKeyword(BlockWorkshopInteractionKeyword)
EndEvent

Function DeleteFDItems()
	Debug.Trace("DeleteFDItems called!", 2)
	int MaxCount = FunctionalDisplaysStructArray.length
	int Count = 0
	While (Count < MaxCount)
		If (FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.DisableNoWait(False)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.Delete()
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef = None
		EndIf
		Count += 1
	EndWhile
EndFunction

Function RecalculateFDItemsInContainer()
	Debug.Trace("RecalculateFDItemsInContainer called!", 2)
	FDItemsInContainer = new Form[0]
	int MaxCount = FunctionalDisplaysStructArray.length
	int count = 0
	int displayedcount = 0
	while (MaxCount > displayedcount && FDContainerItemTypeArray.Length > count)
		FDContainerItemType item = FDContainerItemTypeArray[count]
		int todisplay = Self.Log10(item.count)
		if(count + todisplay > maxcount)
			todisplay = maxcount - count  
		endif
		int displayed = 0
		Debug.Trace("RecalculateFDItemsInContainer: displaying item: "+item.formId+" "+todisplay+" times", 2)
		while (displayed < todisplay)
			FDItemsInContainer.add(item.formObj,1)
			Debug.Trace("RecalculateFDItemsInContainer: added item to display: "+item.formId, 2)
			displayed += 1
		endwhile
		displayedcount += todisplay
		count += 1
	endwhile
EndFunction

Function DisplayFDMountItems()
	Debug.Trace("DisplayFDMountItems called!", 2)
	int MaxCount = FDMountItemsInContainer.length
	If (MaxCount > 0)
		int Count = 0
		While (Count < MaxCount)
		Debug.Trace("DisplayFDMountItems displaying: "+ FDMountItemsInContainer[Count].GetFormID(), 2)
			FDMountStructArray[Count].FDMountItemDisplayRef = Self.PlaceAtNode(FDMountStructArray[Count].FDHorizontalNode, FDMountItemsInContainer[Count], 1, False, False, False, True)
			Self.RegisterForRemoteEvent(FDMountStructArray[Count].FDMountItemDisplayRef, "OnContainerChanged")
			FDMountStructArray[Count].FDMountItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
			FDMountStructArray[Count].FDMountItemDisplayRef.AddKeyword(BlockWorkshopInteractionKeyword)
			FDMountStructArray[Count].FDMountItemDisplayRef.SetNoFavorAllowed(True)
			FDMountStructArray[Count].FDMountItemDisplayRef.SetPlayerHasTaken(True)
			Count += 1
		EndWhile
	EndIf
EndFunction

Function DeleteFDMountItems()
	Debug.Trace("DeleteFDMountItems called!", 2)
	int MaxCount = FDMountStructArray.length
	int Count = 0
	While (Count < MaxCount)
		If (FDMountStructArray[Count].FDMountItemDisplayRef)
			FDMountStructArray[Count].FDMountItemDisplayRef.DisableNoWait(False)
			FDMountStructArray[Count].FDMountItemDisplayRef.Delete()
			FDMountStructArray[Count].FDMountItemDisplayRef = None
		EndIf
		Count += 1
	EndWhile
EndFunction

Function DoThing()
	; Empty function
EndFunction

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	; Empty function
EndEvent

Event OnLoad()
	If (!AlreadyLoaded)
		AlreadyLoaded = True
		FDItemsInContainer = new Form[0]
		FDContainerItemTypeArray = new FDContainerItemType[0]
		FDMountItemsInContainer = new Form[0]
	EndIf
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	; Empty function
EndEvent

int Function Log10(int number)
	int result = 1
	While (number > 10)
		number /= 10
		result += 1
	EndWhile
	return result
EndFunction

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Debug.Trace("OnItemAdded called! aiItemCount: "+ aiItemCount, 2)
	If (akBaseItem.HasKeyword(FDHorizontalKeyword))
		If (FDMountItemsInContainer.length == FDMountStructArray.length)
			Self.RemoveItem(akBaseItem, aiItemCount, False, Game.GetPlayer() as ObjectReference)
			FunctionalDisplaysContainerFullMessage.Show(0, 0, 0, 0, 0, 0, 0, 0, 0)
		Else
			FDMountItemsInContainer.add(akBaseItem, 1)
		EndIf
	EndIf
	If (akBaseItem.HasKeyword(FunctionalDisplaysKeyword) || akBaseItem.HasKeyword(BobbleheadKeyword) || akBaseItem.HasKeyword(PerkMagKeyword) || akBaseItem.HasKeyword(ObjectTypeWeapon) || akBaseItem.HasKeyword(WeaponTypePistol) || akBaseItem.HasKeyword(WeaponTypeRifle) || akBaseItem.HasKeyword(WeaponTypeMelee1H) || akBaseItem.HasKeyword(WeaponTypeMelee2H) || akBaseItem.HasKeyword(WeaponTypeHeavyGun) || akBaseItem.HasKeyword(WeaponTypeHandToHand) || akBaseItem.HasKeyword(WeaponTypeMine) || akBaseItem.HasKeyword(WeaponTypeThrown) || akBaseItem.HasKeyword(WeaponTypeGrenade) || akBaseItem.HasKeyword(ObjectTypeAmmo) || akBaseItem.HasKeyword(ObjectTypeSyringerAmmo) || akBaseItem.HasKeyword(AnimFurnWater) || akBaseItem.HasKeyword(ObjectTypeWater) || akBaseItem.HasKeyword(ObjectTypeDrink) || akBaseItem.HasKeyword(ObjectTypeNukaCola) || akBaseItem.HasKeyword(ObjectTypeAlcohol) || akBaseItem.HasKeyword(ObjectTypeFood) || akBaseItem.HasKeyword(ObjectTypeStimpak) || akBaseItem.HasKeyword(ObjectTypeChem) || akBaseItem.HasKeyword(NotJunkJetAmmo) || akBaseItem.HasKeyword(FeaturedItem))
		Debug.Trace("OnItemAdded: item accepted", 2)
		
		int count = 0
		int hasfound = 0
		while (count < FDContainerItemTypeArray.Length)
			Debug.Trace("OnItemAdded: searching for item type", 2)
			if (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
				FDContainerItemTypeArray[count].count += aiItemCount
				Debug.Trace("OnItemAdded: item type found", 2)
				hasfound = 1
			endif
			count += 1
		endwhile

		if(hasfound == 0)
			FDContainerItemType item = new FDContainerItemType
			item.formId = akBaseItem.GetFormID()
			item.formObj = akBaseItem
			item.count = aiItemCount
			FDContainerItemTypeArray.Add(item)
			Debug.Trace("OnItemAdded: new item type added. Item type count: "+FDContainerItemTypeArray.Length, 2)
		endif
	Else
		Debug.Trace("OnItemAdded: item rejected", 2)
		Self.RemoveItem(akBaseItem, aiItemCount, False, Game.GetPlayer() as ObjectReference)
		FunctionalDisplaysContainerWrongMessage.Show(0, 0, 0, 0, 0, 0, 0, 0, 0)
	EndIf
	Self.RecalculateFDItemsInContainer()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	Self.DeleteFDItems()
	Self.DeleteFDMountItems()
EndEvent

;-- State -------------------------------------------
Auto State AllowActivate

	Event OnActivate(ObjectReference akActionRef)
		Self.GoToState("Busy")
		Self.BlockActivation(True, False)
		Self.AddInventoryEventFilter(None)
		If (akActionRef == Game.GetPlayer() as ObjectReference)
			Self.DeleteFDItems()
			Self.DeleteFDMountItems()
			Self.RecalculateFDItemsInContainer()
			Utility.Wait(0.1)
			Self.DisplayFDItems()
			Self.DisplayFDMountItems()
		EndIf
		Self.GoToState("AllowActivate")
		Self.BlockActivation(False, False)
	EndEvent
EndState

;-- State -------------------------------------------
State Busy
EndState