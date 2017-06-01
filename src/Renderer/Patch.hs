{-# LANGUAGE MultiParamTypeClasses #-}
module Renderer.Patch
( renderPatch
, File(..)
, hunks
, Hunk(..)
, truncatePatch
import qualified Data.ByteString.Char8 as ByteString
import qualified Source
import Source hiding (break, drop, length, null, take)
truncatePatch :: Both SourceBlob -> ByteString
truncatePatch blobs = header blobs <> "#timed_out\nTruncating diff: timeout reached.\n"
renderPatch :: (HasField fields Range, Traversable f) => Both SourceBlob -> Diff f (Record fields) -> File
renderPatch blobs diff = File $ if not (ByteString.null text) && ByteString.last text /= '\n'
  then text <> "\n\\ No newline at end of file\n"
  else text
  where text = header blobs <> mconcat (showHunk blobs <$> hunks diff blobs)

newtype File = File { unFile :: ByteString }
  deriving Show

instance Monoid File where
  mempty = File mempty
  mappend (File a) (File b) = File (a <> "\n" <> b)

instance StringConv File ByteString where
  strConv _ = unFile

showHunk :: Functor f => HasField fields Range => Both SourceBlob -> Hunk (SplitDiff f (Record fields)) -> ByteString
  mconcat (showChange sources <$> changes hunk) <>
showChange :: Functor f => HasField fields Range => Both Source -> Change (SplitDiff f (Record fields)) -> ByteString
showLines :: Functor f => HasField fields Range => Source -> Char -> [Maybe (SplitDiff f (Record fields))] -> ByteString
        prepend source = ByteString.singleton prefix <> source
showLine :: Functor f => HasField fields Range => Source -> Maybe (SplitDiff f (Record fields)) -> Maybe ByteString
showLine source line | Just line <- line = Just . sourceText . (`slice` source) $ getRange line
header :: Both SourceBlob -> ByteString
header blobs = ByteString.intercalate "\n" ([filepathHeader, fileModeHeader] <> maybeFilepaths) <> "\n"
          (Nothing, Just mode) -> ByteString.intercalate "\n" [ "new file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode, Nothing) -> ByteString.intercalate "\n" [ "deleted file mode " <> modeToDigits mode, blobOidHeader ]
          (Just mode1, Just mode2) -> ByteString.intercalate "\n" [
        modeHeader :: ByteString -> Maybe SourceKind -> ByteString -> ByteString
        maybeFilepaths = if (nullOid == oidA && Source.null (snd sources)) || (nullOid == oidB && Source.null (fst sources)) then [] else [ beforeFilepath, afterFilepath ]
        (pathA, pathB) = case runJoin $ toS . path <$> blobs of
hunks :: (Traversable f, HasField fields Range) => Diff f (Record fields) -> Both SourceBlob -> [Hunk (SplitDiff [] (Record fields))]
              , sourcesNull <- runBothWith (&&) (Source.null <$> sources)