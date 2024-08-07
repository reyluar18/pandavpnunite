�
    v��f�  �                   ��   � d dl Z d dlZd dlZd dlZd dlZd� ZdZdZdZdZ	e
dk    rS ej        d�	�  �        Ze�                    d
dd��  �         e�                    �   �         Z eeeee	ej        �  �         dS dS )�    Nc           	      �P  � t          t          j        �                    ||�  �        d�  �        5 }|�                    �   �         }d d d �  �         n# 1 swxY w Y   t          j        |�                    �   �         �  �        �                    �   �         }d|� d|� d|� �}dd| � �i}	d|d�}
t          j
        ||	�	�  �        }|j        d
k    rA|�                    �   �         �
                    dd�  �        }|r||
d<   n?t          d�  �         d S t          d|j        � d��  �         t          |j        �  �         d S t          j        ||	|
��  �        }|j        d
k    rt          d|� d|� d|� d��  �         d S t          d|� d|j        � d��  �         t          |j        �  �         d S )N�rzhttps://api.github.com/repos/�/z
/contents/�Authorizationztoken zUpdate file)�message�content)�headers��   �sha� z+Failed to get the SHA of the existing file.z;Failed to retrieve existing file information. Status code: �.)r	   �jsonzFile 'z' uploaded successfully to zFailed to upload file 'z'. Status code: )�open�os�path�join�read�base64�	b64encode�encode�decode�requests�get�status_coder   �print�text�put)�token�
repo_owner�	repo_name�	file_path�	file_name�filer   �encoded_content�urlr	   �data�responser   s                �	source.py�upload_file_to_githubr)      s  � �	�b�g�l�l�9�i�0�0�#�	6�	6� �$��)�)�+�+��� � � � � � � � � � ���� � � � � �&�w�~�~�'7�'7�8�8�?�?�A�A�O� X�*�
W�
W�y�
W�
W�I�
W�
W�C� 	�)�%�)�)��G� !�"�� �D� �|�C��1�1�1�H���s�"�"��m�m�o�o�!�!�%��,�,��� 	��D��K�K��?�@�@�@��F��c�H�L`�c�c�c�d�d�d��h�m������ �|�C��t�<�<�<�H���s�"�"��V�y�V�V�Z�V�V�)�V�V�V�W�W�W�W�W��Z�	�Z�Z�8�CW�Z�Z�Z�[�[�[��h�m�����s   �A�A�Az<token>�	reyluar03z
script-ipsz!/etc/authorization/pandavpnunite/�__main__z#Register DNS record with Cloudflare)�descriptionz--file_namez	file nameT)�help�required)r   r   r   r   �argparser)   r   �repository_owner�repository_name�local_file_path�__name__�ArgumentParser�parser�add_argument�
parse_args�argsr"   � �    r(   �<module>r;      s�   �� ���� 	�	�	�	� ���� ���� ����+� +� +�\ 	�� � ��� 6�� �z���$�X�$�1V�W�W�W�F�
����K�$��G�G�G������D���%�!1�?�O�UY�Uc�d�d�d�d�d� �r:   