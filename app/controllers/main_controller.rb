class MainController < UICollectionViewController
  CELLIDENTIFIER = "ColorViewCell"

  def loadView
    super
    # UICollectionViewFlowLayout
    layout = self.collectionViewLayout
    layout.minimumLineSpacing = 2.0
    layout.minimumInteritemSpacing = 2
    layout.scrollDirection = UICollectionViewScrollDirectionVertical

    inset = layout.minimumLineSpacing*1.5

    self.collectionView.contentInset = UIEdgeInsetsMake(inset, 0.0, inset, 0.0)
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)

    # self.collectionView.registerClass(UICollectionViewCell.class, forCellWithReuseIdentifier:CELLIDENTIFIER)
  end

  def viewDidLoad
    super
    self.title = "Collection"

    collectionView.tap do |cv|
      # cv.registerClass(ImagesCell, forCellWithReuseIdentifier: IMAGES_CELL_ID)
      cv.delegate = self
      cv.dataSource = self
      cv.emptyDataSetSource = self
      cv.emptyDataSetDelegate = self
      cv.allowsSelection = true
      cv.allowsMultipleSelection = false
      cv.scrollsToTop = true
      # rmq(cv).apply_style :collection_view
    end
  end

  def viewWillAppear(animated)
    super
    self.collectionView.reloadData
  end

  def viewDidAppear animated
    super
    self.collectionView.reloadData
  end


  def columnCount
    return UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation ? kColumnCountMax : kColumnCountMin)
  end

  def cellSize
    flowLayout = self.collectionView.collectionViewLayout
    size = (self.navigationController.view.bounds.size.width/self.columnCount) - flowLayout.minimumLineSpacing
    return CGSizeMake(size, size)
  end

  def filteredPalette
    # Randomly filtered palette
    if !self.filteredPalette
      self.filteredPalette = NSMutableArray.alloc.initWithArray(Palette.sharedPalette.colors)

      for i in self.filteredPalette.count-1 do
        self.filteredPalette.exchangeObjectAtIndex(i, withObjectAtIndex:arc4random_uniform(i+1.0))
      end
    end
    return self.filteredPalette
  end


#pragma mark - Actions

  def refreshColors sender
    Palette.sharedPalette.reloadAll
    self.setFilteredPalette(nil)

    self.collectionView.reloadData
  end


#pragma mark - DZNEmptyDataSetSource Methods

  def titleForEmptyDataSet scrollView
    text = "No colors loaded"

    paragraphStyle = NSMutableParagraphStyle.new
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping
    paragraphStyle.alignment = NSTextAlignmentCenter

    attributes = {
      NSFontAttributeName: UIFont.boldSystemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.colorWithRed(170/255.0, green:171/255.0, blue:179/255.0, alpha:1.0), NSParagraphStyleAttributeName: paragraphStyle
    }

    return NSMutableAttributedString.alloc.initWithString(text, attributes:attributes)
  end

  def descriptionForEmptyDataSet scrollView
    text = "To show a list of random colors, tap on the refresh icon in the right top corner.\n\nTo clean the list, tap on the trash icon."

    paragraphStyle = NSMutableParagraphStyle.new
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping
    paragraphStyle.alignment = NSTextAlignmentCenter

    attributes = {
      NSFontAttributeName: UIFont.systemFontOfSize(15.0), NSForegroundColorAttributeName: UIColor.colorWithRed(170/255.0, green:171/255.0, blue:179/255.0, alpha:1.0), NSParagraphStyleAttributeName: paragraphStyle
    }

    return NSMutableAttributedString.alloc.initWithString(text, attributes:attributes)
  end

  def buttonTitleForEmptyDataSet scrollView, forState: state
    return nil
  end

  def imageForEmptyDataSet scrollView
    return UIImage.imageNamed("empty_placeholder")
  end

  def backgroundColorForEmptyDataSet scrollView
    return UIColor.whiteColor
  end

  def customViewForEmptyDataSet scrollView
    return nil
  end

  def spaceHeightForEmptyDataSet scrollView
    return 0
  end


#pragma mark - DZNEmptyDataSetSource Methods

  def emptyDataSetShouldAllowTouch scrollView
    return true
  end

  def emptyDataSetShouldAllowScroll scrollView
    return true
  end

  def emptyDataSetDidTapView scrollView
    # NSLog(@"%s",__FUNCTION__)
    NSLog("emptyDataSetDidTapView")
  end

  def emptyDataSetDidTapButton scrollView
    NSLog("emptyDataSetDidTapButton")
  end


#pragma mark - UICollectionViewDataSource methods

  def numberOfSectionsInCollectionView collectionView
    return 1
  end

  def collectionView collectionView, numberOfItemsInSection: section
    return self.filteredPalette.count
  end

  def collectionView collectionView, cellForItemAtIndexPath: indexPath
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath:indexPath)
    cell.selectedBackgroundView = UIView.new
    cell.selectedBackgroundView.backgroundColor = UIColor.colorWithWhite(0, alpha:0.25)

    color = self.filteredPalette[indexPath.row]
    cell.backgroundColor = color.color

    return cell
  end


#pragma mark - UICollectionViewDataDelegate methods

  def collectionView collectionView, didSelectItemAtIndexPath: indexPath
    # color = self.filteredPalette[indexPath.row]

    # if self.shouldPerformSegueWithIdentifier("collection_push_detail", sender:color)
    #     self.performSegueWithIdentifier("collection_push_detail", sender:color)
    # }
  end

  def collectionView collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath
    return self.cellSize
  end

  def collectionView collectionView, shouldShowMenuForItemAtIndexPath: indexPath
    return true
  end

  def collectionView collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender
    if NSStringFromSelector(action).isEqualToString("copy:")
      return true
    end
    return false
  end

  # def collectionView collectionView, performAction: action, forItemAtIndexPath: indexPath withSender: sender
  #   # dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ->{
  #   Dispatch::Queue.concurrent.async do
  #     if NSStringFromSelector(action).isEqualToString("copy:")
  #         color = self.filteredPalette[indexPath.row]
  #         if color.hex.length > 0
  #           UIPasteboard.generalPasteboard.setString(color.hex)
  #         end
  #     end
  #   end
  # end


#pragma mark - View Auto-Rotation

  def willRotateToInterfaceOrientation toInterfaceOrientation, duration: duration
    if !UIInputViewController.class
      self.collectionView.reloadData
    end
  end

  def willTransitionToTraitCollection newCollection, withTransitionCoordinator: coordinator
    self.collectionView.reloadData
  end

  def supportedInterfaceOrientations
    return UIInterfaceOrientationMaskAll
  end

  def shouldAutorotate
    return true
  end

end