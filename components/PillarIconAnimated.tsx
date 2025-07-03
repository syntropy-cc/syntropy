import { motion, MotionProps } from "framer-motion";
import { ReactNode } from "react";

interface Props extends MotionProps {
  color: string;   // gradiente principal
  shadow: string;  // cor base do glow
  children: ReactNode;
}

export default function PillarIconAnimated({
  color,
  shadow,
  children,
  ...rest
}: Props) {
  return (
    <motion.div
      {...rest}
      className="relative w-14 h-14 flex items-center justify-center rounded-full overflow-hidden"
      style={{
        background: color,                       // gradiente radial/linear
        border: "3px solid #ffffff33",
        boxShadow: `0 0 24px 6px ${shadow}`,
        perspective: 120,
      }}
      initial={{ boxShadow: `0 0 24px 6px ${shadow}` }}
      animate={{
        boxShadow: [
          `0 0 24px 6px ${shadow}`,
          `0 0 36px 12px ${shadow}55`,
        ],
        scale: [1, 1.08],
      }}
      transition={{ duration: 2, repeat: Infinity }}
      whileHover={{ scale: 1.12 }}
    >
      {/* pseudo-glow interno, já recortado */}
      <span
        className="absolute inset-[-4px] pointer-events-none rounded-full"
        style={{ boxShadow: `0 0 48px 12px ${shadow}55` }}
      />
      {children}
    </motion.div>
  );
} 