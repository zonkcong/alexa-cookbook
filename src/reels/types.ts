export type Reel = {
  id: string;
  src: string; // /videos/reelX.mp4
  username: string;
  caption: string;
  audio: string;
  avatarUrl?: string;
  liked?: boolean;
};
