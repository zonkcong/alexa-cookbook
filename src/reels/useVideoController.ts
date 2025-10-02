import { useCallback, useEffect, useRef, useState } from 'react';

export function useVideoController(isActive: boolean) {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const [isPaused, setIsPaused] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  const [isLiked, setIsLiked] = useState(false);

  const play = useCallback(async () => {
    if (!videoRef.current) return;
    try {
      await videoRef.current.play();
      setIsPaused(false);
    } catch (e) {
      // Autoplay might be blocked; leave paused state
    }
  }, []);

  const pause = useCallback(() => {
    videoRef.current?.pause();
    setIsPaused(true);
  }, []);

  const togglePlay = useCallback(() => {
    if (isPaused) play(); else pause();
  }, [isPaused, play, pause]);

  const toggleMute = useCallback(() => {
    if (!videoRef.current) return;
    videoRef.current.muted = !videoRef.current.muted;
    setIsMuted(videoRef.current.muted);
  }, []);

  const like = useCallback(() => {
    setIsLiked(true);
    const t = setTimeout(() => setIsLiked(false), 800);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!videoRef.current) return;
    videoRef.current.loop = true;
    videoRef.current.playsInline = true;
    videoRef.current.muted = isMuted;
  }, [isMuted]);

  useEffect(() => {
    if (isActive) {
      play();
    } else {
      pause();
    }
  }, [isActive, play, pause]);

  return { videoRef, isPaused, isMuted, isLiked, play, pause, togglePlay, toggleMute, like };
}
