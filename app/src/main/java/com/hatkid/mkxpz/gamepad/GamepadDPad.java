package com.hatkid.mkxpz.gamepad;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.util.AttributeSet;
import android.os.Handler;
import android.os.Looper;

import com.hatkid.mkxpz.utils.DirectionUtils;
import com.hatkid.mkxpz.utils.DirectionUtils.Direction;

public class GamepadDPad extends GamepadButton
{
    private Direction angle = Direction.UNKNOWN;
    public Boolean isDiagonal = false;

    private OnKeyDownListener mOnKeyDownListener = key -> {};
    private OnKeyUpListener mOnKeyUpListener = key -> {};

    private static final long REPEAT_FIRST_DELAY_MS = 300;
    private static final long REPEAT_INTERVAL_MS = 120;

    private final Handler mRepeatHandler = new Handler(Looper.getMainLooper());
    private final Runnable mRepeatRunnable = new Runnable()
    {
        @Override
        public void run()
        {
            if (angle != Direction.UNKNOWN)
            {
                sendDown(angle);
                mRepeatHandler.postDelayed(this, REPEAT_INTERVAL_MS);
            }
        }
    };

    private void startRepeat()
    {
        mRepeatHandler.removeCallbacks(mRepeatRunnable);
        mRepeatHandler.postDelayed(mRepeatRunnable, REPEAT_FIRST_DELAY_MS);
    }

    private void stopRepeat()
    {
        mRepeatHandler.removeCallbacks(mRepeatRunnable);
    }

    private void sendDown(Direction dir)
    {
        switch (dir)
        {
            case UP:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                break;
            case UP_RIGHT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                break;
            case UP_LEFT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                break;
            case DOWN:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                break;
            case DOWN_RIGHT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                break;
            case DOWN_LEFT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                break;
            case RIGHT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                break;
            case LEFT:
                mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                break;
        }
    }

    public void setOnKeyDownListener(OnKeyDownListener onKeyDownListener)
    {
        mOnKeyDownListener = onKeyDownListener;
    }

    public void setOnKeyUpListener(OnKeyUpListener onKeyUpListener)
    {
        mOnKeyUpListener = onKeyUpListener;
    }

    public GamepadDPad(Context context)
    {
        super(context);
    }

    public GamepadDPad(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }

    public GamepadDPad(Context context, AttributeSet attrs, int defStyleAttr)
    {
        super(context, attrs, defStyleAttr);
    }

    public GamepadDPad(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouchEvent(MotionEvent evt)
    {
        float initX = this.getWidth() / 2f;
        float initY = this.getHeight() / 2f;
        float posX;
        float posY;

        switch (evt.getAction())
        {
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_MOVE:
            case MotionEvent.ACTION_POINTER_DOWN:
                posX = evt.getX();
                posY = evt.getY();

                Direction nAngle = DirectionUtils.getAngle(initX, posX, initY, posY, isDiagonal);

                if (angle == nAngle) {
                    return false;
                } else {
                    stopRepeat();
                    switch (angle)
                    {
                        case UP:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                            break;

                        case UP_RIGHT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case UP_LEFT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;

                        case DOWN:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                            break;

                        case DOWN_RIGHT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case DOWN_LEFT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;

                        case RIGHT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case LEFT:
                            mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;
                    }

                    angle = nAngle;

                    switch (angle)
                    {
                        case UP:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                            break;

                        case UP_RIGHT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case UP_LEFT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_UP);
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;

                        case DOWN:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                            break;

                        case DOWN_RIGHT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case DOWN_LEFT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_DOWN);
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;

                        case RIGHT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_RIGHT);
                            break;

                        case LEFT:
                            mOnKeyDownListener.onKeyDown(KeyEvent.KEYCODE_DPAD_LEFT);
                            break;
                    }
                    startRepeat();
                }

                break;

            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_POINTER_UP:
            case MotionEvent.ACTION_OUTSIDE:
                stopRepeat();
                switch (angle)
                {
                    case UP:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                        break;

                    case UP_RIGHT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                        break;

                    case UP_LEFT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_UP);
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                        break;

                    case DOWN:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                        break;

                    case DOWN_RIGHT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                        break;

                    case DOWN_LEFT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_DOWN);
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                        break;

                    case RIGHT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_RIGHT);
                        break;

                    case LEFT:
                        mOnKeyUpListener.onKeyUp(KeyEvent.KEYCODE_DPAD_LEFT);
                        break;
                }

                angle = Direction.UNKNOWN;

                break;
        }

        return true;
    }
}