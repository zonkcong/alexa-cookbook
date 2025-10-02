import React, { useCallback, useMemo, useRef, useState } from 'react';
import { motion, useAnimation, useMotionValue, useTransform } from 'framer-motion';
import { Heart, MessageCircle, Share2, MoreVertical, Camera, ChevronLeft, Volume2, VolumeX } from 'lucide-react';
import { Reel } from './types';
import { useVideoController } from './useVideoController';

type Props = {
  reel: Reel;
  isActive: boolean;
  onDoubleLike?: (id: string) => void;
};

export function ReelItem({ reel, isActive, onDoubleLike }: Props) {
  const { videoRef, isPaused, isMuted, isLiked, togglePlay, toggleMute, like } = useVideoController(isActive);
  const controls = useAnimation();
  const tapTimeout = useRef<number | null>(null);
  const [showHeart, setShowHeart] = useState(false);

  const gradientOverlay = useMemo(() => (
    <div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/40 via-black/10 to-black/60" />
  ), []);

  const handleSingleOrDoubleTap = useCallback(() => {
    if (tapTimeout.current) {
      window.clearTimeout(tapTimeout.current);
      tapTimeout.current = null;
      setShowHeart(true);
      like();
      onDoubleLike?.(reel.id);
      setTimeout(() => setShowHeart(false), 700);
      controls.start({ scale: [1, 1.25, 1], opacity: [0.9, 1, 0.9] }, { type: 'spring', stiffness: 300, damping: 20 });
    } else {
      tapTimeout.current = window.setTimeout(() => {
        togglePlay();
        tapTimeout.current = null;
      }, 200);
    }
  }, [controls, like, onDoubleLike, reel.id, togglePlay]);

  return (
    <div className="relative h-full w-full overflow-hidden">
      <video
        ref={videoRef}
        src={reel.src}
        className="h-full w-full object-cover"
        playsInline
        muted
        onClick={handleSingleOrDoubleTap}
      />

      {gradientOverlay}

      {/* Top bar */}
      <div className="absolute top-0 left-0 right-0 p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="rounded-full bg-black/40 backdrop-blur-md p-2"> <ChevronLeft className="w-5 h-5" /> </div>
          <div className="text-lg font-semibold tracking-wide">Reels</div>
        </div>
        <div className="rounded-full bg-black/40 backdrop-blur-md p-2"> <Camera className="w-5 h-5" /> </div>
      </div>

      {/* Right sidebar */}
      <div className="absolute right-2 bottom-24 flex flex-col items-center gap-5">
        <img src={reel.avatarUrl || 'https://i.pravatar.cc/100'} alt="avatar" className="w-12 h-12 rounded-full border-2 border-white/60" />
        <motion.button whileTap={{ scale: 0.9 }} className="rounded-full bg-black/40 backdrop-blur-md p-3">
          <Heart className={`w-6 h-6 ${isLiked ? 'fill-red-500 text-red-500' : ''}`} />
        </motion.button>
        <motion.button whileTap={{ scale: 0.9 }} className="rounded-full bg-black/40 backdrop-blur-md p-3">
          <MessageCircle className="w-6 h-6" />
        </motion.button>
        <motion.button whileTap={{ scale: 0.9 }} className="rounded-full bg-black/40 backdrop-blur-md p-3">
          <Share2 className="w-6 h-6" />
        </motion.button>
        <motion.button whileTap={{ scale: 0.9 }} className="rounded-full bg-black/40 backdrop-blur-md p-3">
          <MoreVertical className="w-6 h-6" />
        </motion.button>
        <motion.button whileTap={{ scale: 0.9 }} onClick={toggleMute} className="rounded-full bg-black/40 backdrop-blur-md p-3">
          {isMuted ? <VolumeX className="w-6 h-6" /> : <Volume2 className="w-6 h-6" />}
        </motion.button>
      </div>

      {/* Bottom overlay */}
      <div className="absolute left-0 right-0 bottom-0 p-4">
        <div className="rounded-2xl bg-black/30 backdrop-blur-md shadow-glass p-4">
          <div className="flex items-center gap-2 text-sm text-white/90">
            <strong>@{reel.username}</strong>
            <span className="text-white/70">{reel.caption}</span>
          </div>
          <div className="mt-2 text-xs text-white/70">♫ {reel.audio}</div>
        </div>
      </div>

      {/* Double-tap heart */}
      {showHeart && (
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: [0, 1.4, 1], opacity: [0, 1, 0.9] }}
          exit={{ opacity: 0 }}
          transition={{ type: 'spring', stiffness: 200, damping: 12 }}
          className="absolute inset-0 flex items-center justify-center text-red-500/90"
        >
          <Heart className="w-28 h-28" />
        </motion.div>
      )}

      {/* Tap hint */}
      <div className="absolute inset-x-0 bottom-28 flex justify-center text-xs text-white/60">Tap to {isPaused ? 'play' : 'pause'} • Double-tap to like</div>
    </div>
  );
}
